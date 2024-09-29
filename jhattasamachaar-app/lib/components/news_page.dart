// news_page.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jhattasamachaar/components/news_api.dart';
import 'package:jhattasamachaar/components/news_block.dart';
import 'package:jhattasamachaar/components/audio_player_dialog.dart'; // Import the dialog component
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final NewsService newsService = NewsService();
  final Dio dio = Dio();
  final AudioPlayer audioPlayer = AudioPlayer();

  String? mp3FilePath; // Local path to store downloaded MP3
  bool isDownloading = false;
  double downloadProgress = 0.0;

  final String token =
      '19af408ae1c7c7be840108e7344183cd5ba30b31e6f871a5ff2d0dfc062f063c';

  List<dynamic>? newsData; // Store fetched news data

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchNews(); // Fetch news on initialization
  }

  Future<void> fetchNews() async {
    final fetchedNews = await newsService.fetchNews();
    setState(() {
      newsData = fetchedNews; // Store fetched news
    });
  }

  Future<void> downloadAndStoreMP3(String url) async {
    try {
      setState(() {
        isDownloading = true;
      });

      Directory appDir = await getApplicationDocumentsDirectory();
      mp3FilePath = '${appDir.path}/news_audio.mp3';

      // Check if the audio file already exists
      if (!File(mp3FilePath!).existsSync()) {
        await dio.download(
          url,
          mp3FilePath!,
          options: Options(
            headers: {
              'Authorization': 'Token $token',
            },
          ),
          onReceiveProgress: (received, total) {
            if (total != -1) {
              setState(() {
                downloadProgress = received / total;
              });
            }
          },
        );
      }

      setState(() {
        isDownloading = false;
        downloadProgress = 1.0;
      });
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to download audio. Please try again.')),
      );
    }
  }

  void showPlayerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AudioPlayerDialog(
          audioPlayer: audioPlayer,
          mp3FilePath: mp3FilePath,
          resetPlayer: resetPlayer,
        );
      },
    );
  }

  void resetPlayer() {
    audioPlayer.stop();
    setState(() {
      // Reset any state related to the audio player if necessary
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green.shade200,
        onPressed: () async {
          if (mp3FilePath == null || !File(mp3FilePath!).existsSync()) {
            const String mp3Url =
                'https://9m9gxp5m-8000.inc1.devtunnels.ms/api/news/mp3/';
            await downloadAndStoreMP3(mp3Url);
            if (!isDownloading) {
              showPlayerDialog();
            }
          } else {
            showPlayerDialog(); // If already downloaded, directly open the player
          }
        },
        label: isDownloading
            ? CircularProgressIndicator(
                value: downloadProgress,
                backgroundColor: Colors.white,
              )
            : const Text(
                "Read Aloud",
                style: TextStyle(fontSize: 17),
              ),
        icon: const Icon(
          Icons.speaker_phone,
          size: 30,
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.newspaper, size: 30),
            SizedBox(width: 7),
            Text("Latest News Today!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      body: newsData == null
          ? Center(
              child: SizedBox(
                height: 100,
                child: Lottie.asset("lib/assets/animations/loading.json"),
              ),
            )
          : ListView.builder(
              itemCount: newsData!.length,
              itemBuilder: (context, index) {
                var article = newsData![index];
                String title = article['title'] ?? 'No Title';
                String imgurl = article['og_image_url'] ?? "";
                String description = article['summary'] ?? 'No Description';

                return NewsTile(
                  title: title,
                  description: description,
                  imageurl: imgurl,
                );
              },
            ),
    );
  }
}

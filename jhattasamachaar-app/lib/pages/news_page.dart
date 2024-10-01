import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jhattasamachaar/components/news_api.dart';
import 'package:jhattasamachaar/components/news_block.dart';
import 'package:jhattasamachaar/components/audio_player_dialog.dart';
import 'package:jhattasamachaar/globals/api_link.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final NewsService newsService = NewsService();
  final Dio dio = Dio();
  final AudioPlayer audioPlayer = AudioPlayer();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  String? mp3FilePath;
  bool isDownloading = false;
  double downloadProgress = 0.0;
  List<dynamic>? newsData;
  final String api = Globals.link;

  late String mp3Url =
      '$api/api/news/mp3/';

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    final fetchedNews = await newsService.fetchNews();
    setState(() {
      newsData = fetchedNews;
    });
  }

  Future<String?> getToken() async {
    return await secureStorage.read(key: 'auth_token');
  }

  Future<void> downloadMP3(String url) async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      mp3FilePath = '${appDir.path}/news_audio.mp3';

      String? token = await getToken();
      if (token == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }

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

      setState(() {
        isDownloading = false;
        downloadProgress = 1.0; // Download complete
      });
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download audio: $e')),
      );
    }
  }

  Future<void> downloadAndShowPlayer() async {
    setState(() {
      isDownloading = true;
    });

    await downloadMP3(mp3Url);
    showPlayerDialog();
  }

  void showPlayerDialog() {
    showDialog(
      barrierDismissible: false,
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
      downloadProgress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green.shade200,
        onPressed: downloadAndShowPlayer,
        label: isDownloading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  value: downloadProgress,
                  backgroundColor: Colors.white,
                ),
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
            Text(
              "Latest News Today!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
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

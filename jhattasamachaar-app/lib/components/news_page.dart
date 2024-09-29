import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jhattasamachaar/components/news_api.dart';
import 'package:jhattasamachaar/components/news_block.dart';
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
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  final String token =
      '19af408ae1c7c7be840108e7344183cd5ba30b31e6f871a5ff2d0dfc062f063c'; // Replace with your actual token

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
    setupAudioPlayerListeners(); // Set up audio player listeners
  }

  void setupAudioPlayerListeners() {
    audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        totalDuration = duration;
      });
    });

    audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        currentPosition = position;
      });
    });
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
      print('Error downloading MP3: $e');
    }
  }

  Future<void> playAudio() async {
    if (mp3FilePath != null) {
      await audioPlayer.play(DeviceFileSource(mp3FilePath!));
      setState(() {
        isPlaying = true;
      });
    } else {
      print('No MP3 file available to play.');
    }
  }

  Future<void> pauseAudio() async {
    await audioPlayer.pause();
    setState(() {
      isPlaying = false;
    });
  }

  Future<void> resumeAudio() async {
    await audioPlayer.resume();
    setState(() {
      isPlaying = true;
    });
  }

  void showAudioPlayerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Now Playing",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Slider(
                  value: currentPosition.inSeconds.toDouble(),
                  min: 0,
                  max: totalDuration.inSeconds.toDouble() > 0
                      ? totalDuration.inSeconds.toDouble()
                      : 1,
                  onChanged: (value) async {
                    await audioPlayer.seek(Duration(seconds: value.toInt()));
                    setState(() {
                      currentPosition = Duration(seconds: value.toInt());
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatDuration(currentPosition)),
                    Text(formatDuration(totalDuration)),
                  ],
                ),
                const SizedBox(height: 10),
                IconButton(
                  iconSize: 40,
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.green.shade400,
                  ),
                  onPressed: () {
                    if (isPlaying) {
                      pauseAudio();
                    } else {
                      resumeAudio();
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    audioPlayer.stop();
                    Navigator.of(context).pop(); // Close the dialog
                    setState(() {
                      isPlaying = false; // Reset playing state
                    });
                  },
                  child: const Text("Close"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green.shade200,
        onPressed: () async {
          const String mp3Url =
              'https://9m9gxp5m-8000.inc1.devtunnels.ms/api/news/mp3/';
          await downloadAndStoreMP3(mp3Url);
          await playAudio();
          showAudioPlayerDialog();
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

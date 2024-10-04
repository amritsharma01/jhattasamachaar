// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jhattasamachaar/components/news_api.dart';
import 'package:jhattasamachaar/components/audio_player_dialog.dart';
import 'package:jhattasamachaar/components/sample_dialog.dart';
import 'package:jhattasamachaar/components/tokennotfound.dart';
import 'package:jhattasamachaar/globals/api_link.dart';
import 'package:jhattasamachaar/pages/news_detail.dart';
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

  late String mp3Url = '$api/api/news/mp3/';

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
    try {
      final fetchedNews = await newsService.fetchNews(context);
      setState(() {
        newsData = fetchedNews;
      });
    } catch (e) {
      showDialog(
        barrierDismissible: false,
          context: context,
          builder: (context) {
            return SampleDialog(
              title: "Error!",
              description: "Failed to load news, refresh",
              perform: () {},
              buttonText: "Ok",
            );
          });
    }
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
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return const TokenNotFound();
            });
      } else {
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
      }
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

  Future<void> refreshNews() async {
    await fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue.shade600,
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
                "Bulletin",
                style: TextStyle(fontSize: 17, color: Colors.white),
              ),
        icon: const Icon(
          Icons.speaker_phone,
          size: 30,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Latest News Today!",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey.shade100],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: refreshNews,
            color: Colors.blue, // Progress color
            backgroundColor: Colors.white, // Background color of the indicator
            strokeWidth: 3.0, // Adjust thickness
            displacement: 40, // Position of the refresh indicator
            child: newsData == null
                ? Center(
                    child: Lottie.asset(
                      "lib/assets/animations/loading.json",
                      width: 120,
                      height: 120,
                    ),
                  )
                : // Import the news detail page

// Inside your ListView.builder
                ListView.builder(
                    itemCount: newsData!.length,
                    itemBuilder: (context, index) {
                      var article = newsData![index];
                      String title = article['title'] ?? 'No Title';
                      String imgurl = article['og_image_url'] ?? "";
                      String description =
                          article['summary'] ?? 'No Description';
                      String articleUrl = article['source_url'] ??
                          ''; // Assuming you have the article URL

                      return GestureDetector(
                        onTap: () {
                          // Navigate to the NewsDetail page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsDetail(
                                title: title,
                                description: description,
                                imageUrl: imgurl,
                                articleUrl: articleUrl,
                                publishedAt: article['published_at'] ??
                                    'No Date', // New parameter
                                category: article['category'] ??
                                    'No Category', // New parameter
                                sourceName: article['source_name'] ??
                                    'No Source', // New parameter
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 6.0),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (imgurl.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
                                      child: Image.network(
                                        imgurl,
                                        height: 160,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image),
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 12, left: 12, bottom: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        description,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

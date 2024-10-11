// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jhattasamachaar/components/everything_caught_up.dart';
import 'package:jhattasamachaar/components/news_api.dart';
import 'package:jhattasamachaar/components/audio_player_dialog.dart';
import 'package:jhattasamachaar/components/sample_dialog.dart';
import 'package:jhattasamachaar/components/tokennotfound.dart';
import 'package:jhattasamachaar/globals/api_link.dart';
import 'package:jhattasamachaar/pages/news_detail.dart';
import 'package:jhattasamachaar/theme/theme_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

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
  final ScrollController scrollController = ScrollController();
  String? mp3FilePath;
  String? nextUrl;
  bool isDownloading = false;
  bool isLoadingMore = false;
  double downloadProgress = 0.0;
  List<dynamic>? newsData;
  final String api = Globals.link;
  bool clickableFab = true;
  bool isFabVisible = true;

  late String mp3Url = '$api/api/news/mp3/';

  @override
  void dispose() {
    scrollController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchNews();
    scrollController.addListener(onScroll);
  }

  void onScroll() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isLoadingMore) {
      loadMoreNews();
      setState(() {
        isFabVisible = false;
      });
    } else {
      setState(() {
        isFabVisible = true;
      });
    }
  }

  Future<void> fetchNews() async {
    try {
      final fetchedNews = await newsService.fetchNews(context);
      if (!context.mounted) return;
      setState(() {
        newsData = fetchedNews[0];
        nextUrl = fetchedNews[1];
      });
    } catch (e) {
      if (context.mounted) {
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
          },
        );
      }
    }
  }

  Future<void> loadMoreNews() async {
    setState(() {
      isLoadingMore = true; // Show loading indicator
    });

    try {
      final moreNews = await newsService.fetchMoreNews(context);
      if (moreNews[0] != null) {
        setState(() {
          isLoadingMore = false;
        });
      } else {
        setState(() {
          isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingMore = false;
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
        if (context.mounted) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return const TokenNotFound();
            },
          );
        }
      } else {
        try {
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
          String message =
              'An error occurred. Please check your internet connection.';
          if (e is SocketException) {
            message = 'No Internet Connection. Please try again later.';
          }
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) {
                return SampleDialog(
                  title: "Error",
                  description: message,
                  perform: () {},
                  buttonText: "Ok",
                );
              },
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return SampleDialog(
                  title: "Error",
                  description: e.toString(),
                  perform: () {},
                  buttonText: "Ok");
            });
      }
    }
  }

  Future<void> downloadAndShowPlayer() async {
    setState(() {
      isDownloading = true;
      clickableFab = false;
    });

    await downloadMP3(mp3Url);

    if (!isDownloading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download complete!')),
      );
    }

    showPlayerDialog();
  }

  void showPlayerDialog() {
    if (context.mounted) {
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
      ).then((_) {
        // Reset player when dialog is closed
        resetPlayer();
      });
    }
  }

  void resetPlayer() {
    audioPlayer.stop();
    setState(() {
      downloadProgress = 0.0;
      clickableFab = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context)
                        .floatingActionButtonTheme
                        .foregroundColor!,
                    Theme.of(context)
                        .floatingActionButtonTheme
                        .backgroundColor!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: FloatingActionButton.extended(
                backgroundColor:
                    Colors.transparent, // Make background transparent
                onPressed: clickableFab ? downloadAndShowPlayer : () {},
                label: isDownloading
                    ? SizedBox(
                        width: 55,
                        height: 55,
                        child: Lottie.asset(
                            "lib/assets/animations/loading_white.json"),
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
            )
          : null,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).appBarTheme.foregroundColor!,
                Theme.of(context).appBarTheme.backgroundColor!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Latest News Today!",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.titleTextStyle!.color!,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme();
              },
              icon: const Icon(Icons.dark_mode_rounded))
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).colorScheme.surface,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: fetchNews,
            color: Colors.blue,
            backgroundColor: Colors.white,
            strokeWidth: 3.0,
            displacement: 40,
            child: newsData == null
                ? Center(
                    child: Lottie.asset(
                      "lib/assets/animations/loading.json",
                      width: 120,
                      height: 120,
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    itemCount: newsData!.length + 1,
                    itemBuilder: (context, index) {
                      if (index == newsData!.length) {
                        return isLoadingMore
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 24.0),
                                child: Center(
                                  child: Lottie.asset(
                                    "lib/assets/animations/loading.json",
                                    width: 70,
                                    height: 70,
                                  ),
                                ))
                            : const EverythingCaughtUpMessage();
                      }
                      var article = newsData![index];
                      String title = article['title'] ?? 'No Title';
                      String imgurl = article['og_image_url'] ?? "";
                      String description =
                          article['summary'] ?? 'No Description';
                      String articleUrl = article['source_url'] ?? '';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsDetail(
                                title: title,
                                description: description,
                                imageUrl: imgurl,
                                articleUrl: articleUrl,
                                publishedAt:
                                    article['published_at'] ?? 'No Date',
                                category: article['category'] ?? 'No Category',
                                sourceName:
                                    article['source_name'] ?? 'No Source',
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 6.0),
                          child: Card(
                            color: Theme.of(context).cardColor,
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
                                        style:  TextStyle(
                                          color: Theme.of(context).colorScheme.onPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        description,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
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

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:jhattasamachaar/components/news_api.dart'; // Update the import according to your project structure
import 'package:jhattasamachaar/components/news_block.dart'; // Update the import according to your project structure
import 'package:lottie/lottie.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final NewsService newsService = NewsService();
  final FlutterTts flutterTts = FlutterTts();
  final List<Map<String, String>> _newsList = [];

  Future<void> _readTitle(String title) async {
    await flutterTts
        .setVoice({"name": "en-us-x-sfg#male_1-local", "locale": "en-US"});
    await flutterTts.speak(title);
  }

  Future<void> _readDescription(String description) async {
    await flutterTts
        .setVoice({"name": "en-us-x-tpd#male_2-local", "locale": "en-US"});
    await flutterTts.speak(description);
  }

  Future<void> _readNewsArticle(Map<String, String> article) async {
    String title = article['title'] ?? 'No Title';
    String description = article['description'] ?? 'No Description';

    await _readTitle(title);
    await flutterTts.awaitSpeakCompletion(true); // Wait for title to be spoken
    await Future.delayed(const Duration(
        seconds: 1)); // Optional delay between title and description
    await _readDescription(description);
    await flutterTts
        .awaitSpeakCompletion(true); // Wait for description to be spoken
  }

  Future<void> _readAllNews() async {
    for (var news in _newsList) {
      await _readNewsArticle(news);
      await Future.delayed(
          const Duration(seconds: 1)); // Optional delay between articles
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green.shade200,
        onPressed: () {
          // Read all stored news
          _readAllNews();
        },
        label: const Text(
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
            Icon(
              Icons.newspaper,
              size: 30,
            ),
            SizedBox(
              width: 7,
            ),
            Text(
              "Latest News Today!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: newsService.fetchNews(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: SizedBox(
                    height: 100,
                    child: Lottie.asset("lib/assets/animations/loading.json"),
                  ));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No news available.'));
                } else {
                  _newsList.clear();
                  for (var article in snapshot.data!) {
                    String title = article['title'] ?? 'No Title';
                    String description =
                        article['description'] ?? 'No Description';
                    _newsList.add({'title': title, 'description': description});
                  }

                  return ListView.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      var article = _newsList[index];
                      String title = article['title'] ?? 'No Title';
                      String description =
                          article['description'] ?? 'No Description';

                      return NewsTile(
                        title: title,
                        description: description,
                        imageurl:
                            "https://play-lh.googleusercontent.com/_ahCmEdTn8h5omlAg0jg9Y15KArlptm4qcbnyWSzGU-jM4mR1LeArqbMM7DzgZjNywO2",
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

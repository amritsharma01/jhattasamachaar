import 'package:flutter/material.dart';
import 'package:jhattasamachaar/components/news_api.dart';
import 'package:jhattasamachaar/components/news_block.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final NewsService newsService = NewsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text(
          "Read Aloud",
          style: TextStyle(fontSize: 17),
        ),
        icon: const Icon(
          Icons.speaker_rounded,
          size: 30,
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(),
      body: FutureBuilder<List<dynamic>>(
        future: newsService.fetchNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No news available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var article = snapshot.data![index];
                return NewsTile(
                  title: article['title'],
                  description: article['description'] ?? 'No description',
                  imageurl:
                      "https://play-lh.googleusercontent.com/_ahCmEdTn8h5omlAg0jg9Y15KArlptm4qcbnyWSzGU-jM4mR1LeArqbMM7DzgZjNywO2",
                );
              },
            );
          }
        },
      ),
    );
  }
}

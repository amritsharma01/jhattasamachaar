import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetail extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String articleUrl;
  final String publishedAt; // New parameter
  final String category; // New parameter
  final String sourceName; // New parameter

  const NewsDetail({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.articleUrl,
    required this.publishedAt,
    required this.category,
    required this.sourceName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).colorScheme.onPrimary,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8.0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 100),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Displaying the title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Displaying the published date
                      Text(
                        'Published on: $publishedAt',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Displaying the category and source name
                      Row(
                        children: [
                          _buildSimpleTextButton(category, Colors.teal),
                          const SizedBox(width: 10),
                          _buildSimpleTextButton(sourceName, Colors.blueAccent),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Displaying the description with justified alignment
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          description,
                          style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.tertiary),
                          textAlign: TextAlign.justify, // Justified alignment
                        ),
                      ),

                      // Link to open the full article
                      GestureDetector(
                        onTap: () {
                          launchURL(articleUrl);
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Theme.of(context)
                                      .buttonTheme
                                      .colorScheme!
                                      .primary),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 13),
                                child: Text(
                                  "Read Full Article",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to build a simple text button
  Widget _buildSimpleTextButton(String text, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Function to launch URL
  void launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}

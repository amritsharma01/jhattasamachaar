import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  final String apiUrl =
      'https://newsapi.org/v2/everything?q=tesla&from=2024-08-03&sortBy=publishedAt&apiKey=811555dafb954162973fdcf63cb23968'; 

  Future<List<dynamic>> fetchNews() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // Parse the JSON data
      return json.decode(response.body)['articles'];
    } else {
      throw Exception('Failed to load news');
    }
  }
}

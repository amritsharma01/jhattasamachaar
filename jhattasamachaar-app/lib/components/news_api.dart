import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  final String apiUrl = 'https://9m9gxp5m-8000.inc1.devtunnels.ms/api/news/';
  final token =
      '19af408ae1c7c7be840108e7344183cd5ba30b31e6f871a5ff2d0dfc062f063c';

  Future<List<dynamic>> fetchNews() async {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Token $token',
      },
    );
    if (response.statusCode == 200) {
      // Parse the JSON data
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to load news');
    }
  }
}

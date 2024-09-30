import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jhattasamachaar/globals/api_link.dart';

class NewsService {
  final String api = Globals.link; 
  late final String apiUrl = '$api/api/news/'; 
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<List<dynamic>> fetchNews() async {
    await secureStorage.write(
        key: 'auth_token',
        value:
            "6ca2c9021676b61b13484067f6f6c664df98e6bd94264219d02a60b25ee2e1fd");
    final token = await secureStorage.read(key: 'auth_token');
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to load news');
    }
  }
}

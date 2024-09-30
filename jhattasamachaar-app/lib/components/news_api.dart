import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NewsService {
  final String apiUrl = 'https://9m9gxp5m-8000.inc1.devtunnels.ms/api/news/';
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<List<dynamic>> fetchNews() async {
    await secureStorage.write(
        key: 'auth_token',
        value:
            "252c88607bb009794854051ba291209dd889cb005f38272dd586a54304b417b2");
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

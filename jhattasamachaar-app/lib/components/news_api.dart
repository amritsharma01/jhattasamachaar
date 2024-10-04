// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jhattasamachaar/components/sample_dialog.dart';
import 'package:jhattasamachaar/components/tokennotfound.dart';
import 'package:jhattasamachaar/globals/api_link.dart';

class NewsService {
  final String api = Globals.link;
  late final String apiUrl = '$api/api/news/';
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<List<dynamic>> fetchNews(BuildContext context) async {
    //retrieve the token from secure storage
    final token = await secureStorage.read(key: 'auth_token');
    if (token == null) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return const TokenNotFound();
          });
    }

    else{
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode.toString().startsWith("2")) {
        return json.decode(response.body)['results'];
      } else {
        showDialog(
          barrierDismissible: false,
            context: context,
            builder: (context) {
              return SampleDialog(
                  title: "Error",
                  description: "Failed to load news, Refresh",
                  perform: () {},
                  buttonText: "Ok");
            });
        
      }
    }
    throw Exception("Error");
  }
}

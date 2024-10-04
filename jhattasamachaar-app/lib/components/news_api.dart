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
    // Retrieve the token from secure storage
    final token = await secureStorage.read(key: 'auth_token');
    // Check for token presence
    if (token == null) {
      if (context.mounted) {
        // Ensure context is still valid before using it
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return const TokenNotFound();
          },
        );
      }
      return []; // Return an empty list if the token is not found
    } else {
      try {
        // Make the request
        final response = await http.get(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Token $token',
          },
        );

        // Check for success status
        if (response.statusCode.toString().startsWith("2")) {
          return json.decode(response.body)['results'];
        } else {
          if (context.mounted) {
            // Ensure context is valid before showing a dialog
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return SampleDialog(
                  title: "Error",
                  description: "Failed to load news, Refresh",
                  perform: () {},
                  buttonText: "Ok",
                );
              },
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          // Optional: you can show another dialog for catching the specific error
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return SampleDialog(
                title: "Error",
                description: "Something went wrong: $e",
                perform: () {},
                buttonText: "Ok",
              );
            },
          );
        }
      }
    }
    // If something went wrong, return an empty list
    return [];
  }
}

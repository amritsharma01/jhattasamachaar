// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
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
  List<dynamic> newsdata = [];
  String? nextUrl;

  Future<List<dynamic>> fetchNews(BuildContext context) async {
    final token = await secureStorage.read(key: 'auth_token');
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
      return [];
    } else {
      try {
        final response = await http.get(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Token $token',
          },
        );

        if (response.statusCode.toString().startsWith("2")) {
          // Initial load of news data
          newsdata = json.decode(response.body)["results"];
          nextUrl = json.decode(response.body)["next"];

          // Replace 'localhost' in the nextUrl if present
          if (nextUrl != null && nextUrl!.contains("http://localhost:8000")) {
            nextUrl = nextUrl!.replaceAll("http://localhost:8000", api);
          }
          return [newsdata, nextUrl];
        } else if (response.statusCode == 401) {
          secureStorage.delete(key: "auth_token");
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
          if (context.mounted) {
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
    return [];
  }

  Future<List<dynamic>> fetchMoreNews(BuildContext context) async {
    final token = await secureStorage.read(key: 'auth_token');
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
      return [];
    }
    else if(nextUrl==null){
     
    }
    
    else {
      try {
        // Replace 'localhost' in the nextUrl if present
        if (nextUrl!.contains("http://localhost:8000")) {
          nextUrl = nextUrl!.replaceAll("http://localhost:8000", api);
        }

        final response = await http.get(
          Uri.parse(nextUrl!),
          headers: {
            'Authorization': 'Token $token',
          },
        );

        if (response.statusCode.toString().startsWith("2")) {
          // Append new data to the existing list
          final newNewsData = json.decode(response.body)["results"];
          newsdata.addAll(newNewsData);

          // Update nextUrl for subsequent fetches
          nextUrl = json.decode(response.body)["next"];

          // Replace 'localhost' in the nextUrl if present
          if (nextUrl != null && nextUrl!.contains("http://localhost:8000")) {
            nextUrl = nextUrl!.replaceAll("http://localhost:8000", api);
          }

          return [newsdata, nextUrl];
        }
        else if (response.statusCode == 401) {
          secureStorage.delete(key: "auth_token");
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
          if (context.mounted) {
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
        // Handle error
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
    return [];
  }
}

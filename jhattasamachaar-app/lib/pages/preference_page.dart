// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jhattasamachaar/components/category_model.dart';
import 'package:jhattasamachaar/components/sample_dialog.dart';
import 'package:jhattasamachaar/components/tokennotfound.dart';
import 'package:jhattasamachaar/globals/api_link.dart';
import 'package:jhattasamachaar/pages/home_page.dart';
import 'package:lottie/lottie.dart';

class Preference extends StatefulWidget {
  const Preference({super.key, required this.isUpdating});

  final bool isUpdating;

  @override
  State<Preference> createState() => _PreferenceState();
}

class _PreferenceState extends State<Preference> {
  final String api = Globals.link;
  List<Category> categories = [];
  List<int> dislikes = [];
  List<int> likes = [];
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchCategories().then((fetchedCategories) {
      setState(() {
        categories = fetchedCategories;
      });
    });
    if (widget.isUpdating) {
      fetchUserPreferences(); // Fetch preferences if updating
    }
  }

  Future<List<Category>> fetchCategories() async {
    final token = await secureStorage.read(key: 'auth_token');
    if (token == null) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return const TokenNotFound();
          });
    } else {
      showDialog(
          context: context,
          builder: (context) {
            bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
            return Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: Lottie.asset(
                  isDarkMode
                      ? 'lib/assets/animations/loading_white.json'
                      : 'lib/assets/animations/loading.json', // Update with your Lottie animation file path
                ),
              ),
            );
          });
      try {
        final response = await http.get(
          Uri.parse('$api/api/news/category/'),
          headers: {
            'Authorization': 'Token $token',
          },
        );

        if (response.statusCode.toString().startsWith("2")) {
          Navigator.pop(context);
          final List<dynamic> data = json.decode(response.body);
          return data.map((json) => Category.fromJson(json)).toList();
        } else {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (context) {
              return SampleDialog(
                title: "Error",
                description: "Failed to load categories",
                perform: () {
                  Navigator.pop(context);
                },
                buttonText: "Close",
              );
            },
          );
          return [];
        }
      } catch (error) {
        Navigator.pop(context); // Close loading dialog
        String message =
            'An error occurred. Please check your internet connection.';
        if (error is SocketException) {
          message = 'No Internet Connection. Please try again later.';
        }
        showDialog(
          context: context,
          builder: (context) {
            return SampleDialog(
              title: "Error",
              description: message,
              perform: () {
                Navigator.pop(context);
              },
              buttonText: "Ok",
            );
          },
        );
        return []; // Return an empty list on error
      }
    }
    return [];
  }

  Future<void> fetchUserPreferences() async {
    final token = await secureStorage.read(key: 'auth_token');
    if (!widget.isUpdating) return; // Only fetch preferences when updating
    if (token == null) {
      showDialog(
          context: context,
          builder: (context) {
            return const TokenNotFound();
          });
    } else {
      showDialog(
          context: context,
          builder: (context) {
            bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
            return Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: Lottie.asset(
                  isDarkMode
                      ? 'lib/assets/animations/loading_white.json'
                      : 'lib/assets/animations/loading.json', // Update with your Lottie animation file path
                ),
              ),
            );
          });
      try {
        final response = await http.get(
          Uri.parse('$api/api/auth/profile/'),
          headers: {
            'Authorization': 'Token $token',
          },
        );

        if (response.statusCode.toString().startsWith("2")) {
          Navigator.pop(context);
          final data = json.decode(response.body);
          setState(() {
            likes = (data['likes'] as List)
                .map((like) => like['id'] as int)
                .toList();
            // dislikes = (data['dislikes'] as List)
            //     .map((dislike) => dislike['id'] as int)
            //     .toList();
          });
        } else {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) {
                return SampleDialog(
                    title: "Error",
                    description: "Failed to fetch preferences",
                    perform: () {
                      Navigator.pop(context);
                    },
                    buttonText: "Close");
              });
        }
      } catch (error) {
        Navigator.pop(context); // Close loading dialog
        String message =
            'An error occurred. Please check your internet connection.';
        if (error is SocketException) {
          message = 'No Internet Connection. Please try again later.';
        }
        showDialog(
          context: context,
          builder: (context) {
            return SampleDialog(
              title: "Error",
              description: message,
              perform: () {
                Navigator.pop(context);
              },
              buttonText: "Ok",
            );
          },
        );
        // Return an empty list on error
      }
    }
  }

  void togglePreference(int id) {
    setState(() {
      if (likes.contains(id)) {
        likes.remove(id); // Remove if already liked
      } else {
        likes.add(id); // Add to likes if selected
      }
    });
  }

  void addPreferences() async {
    final token = await secureStorage.read(key: 'auth_token');

    // Check if the token is null
    if (token == null) {
      showDialog(
        context: context,
        builder: (context) {
          return const TokenNotFound();
        },
      );
      return; // Exit the function if the token is not found
    }

    // dislikes = categories
    //     .where((category) => !likes.contains(category.id))
    //     .map((category) => category.id)
    //     .toList(); // Auto-fill dislikes with categories not liked

    showDialog(
      context: context,
      builder: (context) {
        bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: Lottie.asset(
              isDarkMode
                  ? "'lib/assets/animations/loading_white.json'"
                  : 'lib/assets/animations/loading.json',
            ),
          ),
        );
      },
    );

    try {
      final response = await http.post(
        Uri.parse('$api/api/auth/preferences/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'likes': likes,
          'dislikes': dislikes,
        }),
      );

      if (response.statusCode.toString().startsWith("2")) {
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) {
            return const HomePage();
          }),
          (Route<dynamic> route) {
            return false;
          },
        );
        showDialog(
          context: context,
          builder: (context) {
            return SampleDialog(
              title: "Success",
              description: "Preferences added Successfully",
              perform: () {},
              buttonText: "Close",
            );
          },
        );
      } else {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return SampleDialog(
              title: "Error",
              description: "Failed to add preferences",
              perform: () {},
              buttonText: "Close",
            );
          },
        );
      }
    } catch (error) {
      Navigator.pop(context); // Close loading dialog
      String message =
          'An error occurred. Please check your internet connection.';
      if (error is SocketException) {
        message = 'No Internet Connection. Please try again later.';
      }
      showDialog(
        context: context,
        builder: (context) {
          return SampleDialog(
            title: "Error",
            description: message,
            perform: () {
              Navigator.pop(context);
            },
            buttonText: "Ok",
          );
        },
      );
    }
  }

  void updatePreferences() async {
    final token = await secureStorage.read(key: 'auth_token');

    // Check if the token is null
    if (token == null) {
      showDialog(
        context: context,
        builder: (context) {
          return const TokenNotFound();
        },
      );
      return; // Exit the function if the token is not found
    }

    // dislikes = categories
    //     .where((category) => !likes.contains(category.id))
    //     .map((category) => category.id)
    //     .toList(); // Update dislikes with unselected categories

    showDialog(
      context: context,
      builder: (context) {
        bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: Lottie.asset(
              isDarkMode
                  ? "lib/assets/animations/loading_white.json"
                  : 'lib/assets/animations/loading.json',
            ),
          ),
        );
      },
    );

    try {
      final response = await http.post(
        Uri.parse('$api/api/auth/preferences/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'likes': likes,
          'dislikes': dislikes,
        }),
      );

      if (response.statusCode.toString().startsWith("2")) {
        Navigator.pop(context);
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return SampleDialog(
              title: "Success",
              description: "Preferences Updated Successfully",
              perform: () {},
              buttonText: "Close",
            );
          },
        );
      } else {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return SampleDialog(
              title: "Error",
              description: "Failed to update preferences",
              perform: () {},
              buttonText: "Close",
            );
          },
        );
      }
    } catch (error) {
      Navigator.pop(context); // Close loading dialog
      String message =
          'An error occurred. Please check your internet connection.';
      if (error is SocketException) {
        message = 'No Internet Connection. Please try again later.';
      }
      showDialog(
        context: context,
        builder: (context) {
          return SampleDialog(
            title: "Error",
            description: message,
            perform: () {
              Navigator.pop(context);
            },
            buttonText: "Ok",
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).colorScheme.onPrimary,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          !widget.isUpdating
              ? GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return const HomePage();
                      }),
                      (Route<dynamic> route) {
                        return false;
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Container(
                      width: 70,
                      decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.black54
                              : Colors.green.shade200,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text(
                          "Skip",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()
        ],
        automaticallyImplyLeading: widget.isUpdating,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "Select your preferred categories",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = likes.contains(category.id);

                  return GestureDetector(
                    onTap: () {
                      togglePreference(category.id);
                    },
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: isSelected
                          ? Theme.of(context).buttonTheme.colorScheme!.primary
                          : Theme.of(context)
                              .buttonTheme
                              .colorScheme!
                              .secondary,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "lib/assets/images/${category.name.toLowerCase()}.png",
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          GestureDetector(
            onTap: widget.isUpdating ? updatePreferences : addPreferences,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).buttonTheme.colorScheme!.primary,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "Submit Preferences",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

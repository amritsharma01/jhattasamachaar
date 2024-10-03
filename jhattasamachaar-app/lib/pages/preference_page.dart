import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jhattasamachaar/components/category_model.dart';
import 'package:jhattasamachaar/globals/api_link.dart';
import 'package:jhattasamachaar/pages/home_page.dart';

class Preference extends StatefulWidget {
  final bool isUpdating;

  const Preference({super.key, required this.isUpdating});

  @override
  State<Preference> createState() => _PreferenceState();
}

class _PreferenceState extends State<Preference> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final String api = Globals.link;
  List<Category> categories = [];
  List<int> likes = [];
  List<int> dislikes = [];

  Future<List<Category>> fetchCategories() async {
    final token = await secureStorage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse('$api/api/news/category/'),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode.toString().startsWith("2")) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> fetchUserPreferences() async {
    final token = await secureStorage.read(key: 'auth_token');
    if (!widget.isUpdating) return; // Only fetch preferences when updating

    final response = await http.get(
      Uri.parse('$api/api/auth/profile/'),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        likes =
            (data['likes'] as List).map((like) => like['id'] as int).toList();
        dislikes = (data['dislikes'] as List)
            .map((dislike) => dislike['id'] as int)
            .toList();
      });
    } else {
      throw Exception('Failed to fetch preferences');
    }
  }

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
    dislikes = categories
        .where((category) => !likes.contains(category.id))
        .map((category) => category.id)
        .toList(); // Auto-fill dislikes with categories not liked

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

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences saved successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save preferences!')),
      );
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) {
      return const HomePage();
    }));
  }

  void updatePreferences() async {
    final token = await secureStorage.read(key: 'auth_token');
    dislikes = categories
        .where((category) => !likes.contains(category.id))
        .map((category) => category.id)
        .toList(); // Update dislikes with unselected categories

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update preferences!')),
      );
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) {
      return const HomePage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        actions: [
          !widget.isUpdating
              ? GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (builder) {
                      return const HomePage();
                    }));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Container(
                      width: 70,
                      decoration: BoxDecoration(
                          color: Colors.green.shade200,
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
        backgroundColor: Colors.white,
        automaticallyImplyLeading: widget.isUpdating,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Select your preferred categories",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
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
                          ? Colors.lightBlueAccent.withOpacity(0.3)
                          : Colors.white,
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade300,
                        Colors.blue.shade700,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )),
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

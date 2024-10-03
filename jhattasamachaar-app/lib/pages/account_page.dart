// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:jhattasamachaar/components/settings_tile.dart';
import 'package:jhattasamachaar/globals/api_link.dart';
import 'package:jhattasamachaar/pages/about_us_page.dart';
import 'package:jhattasamachaar/pages/login_page.dart';
import 'package:jhattasamachaar/pages/preference_page.dart';
import 'package:launch_review/launch_review.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_flutter/qr_flutter.dart'; // QR code generation package

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String name = 'User';
  String email = "user@user.com";
  String photoUrl = "lib/assets/images/user.png"; // Local fallback image
  List<dynamic> likes = [];
  List<dynamic> dislikes = [];
  final String api = Globals.link;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String? token = await secureStorage.read(key: 'auth_token');

    final response = await http.get(
      Uri.parse('$api/api/auth/profile/'),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final profileData = jsonDecode(response.body);

      setState(() {
        // Update the data extraction according to the new response structure
        name = profileData['user']['first_name'] +
                " " +
                profileData['user']['last_name'] ??
            'User';
        email = profileData['user']['email'] ?? 'user@user.com';
        photoUrl = profileData['picture'] ?? 'lib/assets/images/user.png';

        // Extract likes and dislikes from the new response structure
        likes = profileData['likes']
                ?.map((like) => {
                      'name': like['name'],
                    })
                .toList() ??
            [];

        dislikes = profileData['dislikes']
                ?.map((dislike) => {
                      'name': dislike['name'],
                    })
                .toList() ??
            [];
      });
    } else {
      // Handle error here, maybe show a message to the user.
      print('Failed to fetch profile data: ${response.body}');
    }
  }

  void showQr() {
    final qrData = {
      'name': name,
      'email': email,
      'likes': likes,
      'dislikes': dislikes,
    };

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
              child: Text(
            "QR Code",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          )),
          content: SizedBox(
            // Provide a defined size for the QR code
            width: 250,
            height: 250,
            child: QrImageView(
              data: jsonEncode(qrData), // QR data
              version: QrVersions.auto, // Automatically adjust QR complexity
              size: 200.0, // Size of the QR image inside the dialog
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade300,
                            Colors.blue.shade700,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: Text(
                        "Close",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void rateUs() async {
    await LaunchReview.launch(androidAppId: "com.example.app", iOSAppId: "");
  }

  void signOut() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Log Out",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          content: const Text(
            "Are you sure you want to log out?",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          actions: [
            // No Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey
                    .shade400, // Use a grey background to differentiate from "Yes"
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Text(
                  "No",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white, // White text for contrast
                  ),
                ),
              ),
            ),

            // Yes Button
            ElevatedButton(
              onPressed: () async {
                // Show loading animation
                showDialog(
                  barrierColor: Colors.black54,
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return Center(
                      child: SizedBox(
                        height: 100,
                        child:
                            Lottie.asset("lib/assets/animations/loading.json"),
                      ),
                    );
                  },
                );

                const FlutterSecureStorage secureStorage =
                    FlutterSecureStorage();
                String? token = await secureStorage.read(key: 'auth_token');

                final response = await http.post(
                  Uri.parse('$api/api/auth/logout/'),
                  headers: {
                    'Authorization': 'Token $token',
                    'Content-Type': 'application/json',
                  },
                );

                if (response.statusCode == 204) {
                  await FirebaseAuth.instance.signOut();
                  await GoogleSignIn().signOut();
                  Navigator.pop(context); // Close loading dialog
                  Navigator.pop(context);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return const Login();
                  }));
                } else {
                  Navigator.pop(context); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Backend logout failed: ${response.body}')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Text(
                  "Yes",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            // Profile picture with shadow
            Center(
              child: Container(
                decoration: const BoxDecoration(),
                child: Image.asset(
                  photoUrl,
                  fit: BoxFit.cover,
                  height: 150,
                  width: 150,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'lib/assets/images/user.png',
                    height: 150,
                    width: 150,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Name and Email
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  email,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(height: 2, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 20),
            // Settings Tiles
            SettingsTile(
              icon: Icons.qr_code_2_rounded,
              name: "QR",
              color: Colors.white,
              ontap: showQr,
            ),
            SettingsTile(
              icon: Icons.monitor_heart,
              name: "Preferences",
              color: Colors.white,
              ontap: () {
                Navigator.push(context, MaterialPageRoute(builder: ((context) {
                  return const Preference(isUpdating: true);
                })));
              },
            ),
            SettingsTile(
              icon: Icons.phone,
              name: "Contact Us",
              color: Colors.white,
              ontap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AboutUsPage();
                }));
              },
            ),
            SettingsTile(
              icon: Icons.star,
              name: "Rate Us",
              color: Colors.white,
              ontap: rateUs,
            ),
            SettingsTile(
              icon: Icons.logout_sharp,
              name: "Log Out",
              color: Colors.blue.shade300,
              ontap: signOut,
            ),
          ],
        ),
      ),
    );
  }
}

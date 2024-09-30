import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:jhattasamachaar/components/settings_tile.dart';
import 'package:launch_review/launch_review.dart';
import 'package:lottie/lottie.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  User? user;
  String name = 'User';
  String email = "user@user.com";
  String photoUrl = "lib/assets/images/user.png";

  @override
  void initState() {
    super.initState();
    // Get the current user and set the username
    user = FirebaseAuth.instance.currentUser;
    if (user != null && user!.displayName != null && user!.email != null) {
      setState(() {
        name = user!.displayName!;
        email = user!.email!;
      });
    }
    if (user != null && user!.photoURL != null && user!.photoURL!.isNotEmpty) {
      setState(() {
        photoUrl = user!.photoURL!;
      });
    } else {
      // Set a default image or a placeholder
      photoUrl = "lib/assets/images/user.png";
    }
  }

  void showQr() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: const Text("QR Code"),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green.shade300,
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Close",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
        return AlertDialog.adaptive(
          title: const Text("Log Out"),
          content: const Text("Are you sure you want to Log Out?"),
          actions: [
            GestureDetector(
              onTap: () async {
                // Show a loading dialog during sign out
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
                
                // Retrieve the token from secure storage
                const FlutterSecureStorage secureStorage =
                    FlutterSecureStorage();
                String? token = await secureStorage.read(key: 'auth_token');
                  print(token);
                // Send a POST request to the backend to log out
                final response = await http.post(
                  Uri.parse(
                      'https://9m9gxp5m-8000.inc1.devtunnels.ms/api/auth/logout/'), // Replace with your backend logout URL
                  headers: {
                    'Authorization':
                        'Token $token', 
                    'Content-Type': 'application/json',
                  },
                );

                if (response.statusCode == 204) {
                  // Successfully logged out from backend
                  await GoogleSignIn().signOut();
                  await FirebaseAuth.instance.signOut();
                  Navigator.pop(context); // Close the loading dialog
                  Navigator.pop(context); // Go back to the previous screen
                } else {
                  // Handle error from backend
                  Navigator.pop(context); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Backend logout failed: ${response.body}')),
                  );
                }
              },
              child: Container(
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green.shade300,
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Yes",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green.shade300,
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "No",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
            const SizedBox(
              height: 15,
            ),
            Center(
              child: ClipOval(
                child: Image.network(
                  fit: BoxFit.cover,
                  photoUrl,
                  height: 150,
                  width: 150,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Colors.grey[800]),
                ),
                const SizedBox(
                  height: 1,
                ),
                Text(
                  email,
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.grey[500]),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(height: 2, color: Colors.grey.shade500),
            ),
            const SizedBox(
              height: 20,
            ),
            SettingsTile(
              icon: Icons.qr_code_2_rounded,
              name: "QR",
              color: Colors.grey.shade300,
              ontap: showQr,
            ),
            SettingsTile(
              icon: Icons.notification_important_rounded,
              name: "Notifications",
              color: Colors.grey.shade300,
              ontap: () {},
            ),
            SettingsTile(
              icon: Icons.phone,
              name: "Contact Us",
              color: Colors.grey.shade300,
              ontap: () {},
            ),
            SettingsTile(
              icon: Icons.star,
              name: "Rate Us",
              color: Colors.grey.shade300,
              ontap: rateUs,
            ),
            SettingsTile(
              icon: Icons.logout_sharp,
              name: "Log Out",
              color: Colors.green.shade300,
              ontap: signOut,
            ),
          ],
        ),
      ),
    );
  }
}

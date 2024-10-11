// ignore_for_file: use_build_context_synchronously
import 'dart:convert'; // For jsonEncode
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jhattasamachaar/globals/api_link.dart';
import 'package:jhattasamachaar/pages/home_page.dart';
import 'package:jhattasamachaar/pages/preference_page.dart';
import 'package:lottie/lottie.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final String api = Globals.link;
  bool isNew = true;
  Future<UserCredential?> signInWithGoogle() async {
    BuildContext? dialogContext;

    try {
      // Check if user is already signed in
      final currentUser = googleSignIn.currentUser;

      // Sign out if there is a currently signed-in user
      if (currentUser != null) {
        await googleSignIn.signOut();
        await FirebaseAuth.instance.signOut();
      }

      showDialog(
        barrierColor: Colors.black54,
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
          dialogContext = ctx;
          return Center(
            child: SizedBox(
              height: 100,
              child: Lottie.asset(isDarkMode
                  ? "lib/assets/animations/loading_white.json"
                  : 'lib/assets/animations/loading.json'),
            ),
          );
        },
      );

      // Start Google sign-in process
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        Navigator.pop(context);
        return null;
        // if the  user canceled the sign-in process
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Send ID token to the backend
      final idToken = await userCredential.user?.getIdToken();
      if (idToken != null) {
        await sendIdTokenToBackend(idToken);
      }
      if (dialogContext != null) {
        Navigator.pop(dialogContext!); // Close the loading dialog
      }

      if (isNew) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const Preference(
            isUpdating: false,
          );
        }));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const HomePage();
        }));
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // Close the loading dialog in case of an error
      if (dialogContext != null) {
        Navigator.pop(dialogContext!);
      }
      // Check if the widget is still mounted before using context
      if (!mounted) return null;
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text("ERROR!", style: TextStyle(color: Colors.red[500])),
            content:
                Text(e.message ?? "An error occurred during Google sign-in."),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text("OK",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Close the loading dialog in case of a general error
      if (dialogContext != null) {
        Navigator.pop(dialogContext!);
      }
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text("ERROR!", style: TextStyle(color: Colors.red[500])),
            content: const Text("An error occurred during Google sign-in."),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text("OK",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    }
    return null;
  }

  //finction to send users token to backend server
  Future<void> sendIdTokenToBackend(String idToken) async {
    String backendUrl = '$api/api/auth/google/';

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'id_token': idToken,
        }),
      );

      if (response.statusCode.toString().startsWith("2")) {
        // Parse the response to get the token and new_user status from the backend
        final Map<String, dynamic> responseData = json.decode(response.body);
        final token = responseData['token'];
        final bool isNewUser = responseData['new_user'];
        setState(() {
          isNew = isNewUser;
        });
        // Store the token securely
        await secureStorage.write(key: 'auth_token', value: token);
      } else {
        // show error dialog when authentication with backend is failed
        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: Text("ERROR!", style: TextStyle(color: Colors.red[500])),
              content: Text(
                  "Failed to authenticate with server${response.statusCode.toString()}, try again"),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: const Text("OK",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // show error dialog when token cant be sent to server due to some reasons
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text("ERROR!", style: TextStyle(color: Colors.red[500])),
            content: Text(e.toString()),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text("OK",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.grey.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo and Text Section
                const SizedBox(height: 80), // Space at the top
                SizedBox(
                  height: 150, // Logo height
                  child: Center(
                    child: Image.asset("lib/assets/logo/logo.png"),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Hello",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black38,
                        offset: Offset(3.0, 3.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Get the Latest News Summaries",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Custom Divider with soft edges
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 3,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 150), // Pushes the button lower

                // Sign-in Button Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: GestureDetector(
                    onTap: signInWithGoogle,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            spreadRadius: 5,
                            blurRadius: 15,
                            offset: const Offset(
                                0, 5), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "lib/assets/images/google.png",
                            height: 30,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Sign in with Google",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50), // Space at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}

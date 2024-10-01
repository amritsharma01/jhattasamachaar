import 'dart:convert'; // For jsonEncode
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jhattasamachaar/globals/api_link.dart';
import 'package:jhattasamachaar/pages/home_page.dart';
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

      // Show loading dialog
      showDialog(
        barrierColor: Colors.black54,
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          dialogContext = ctx;
          return Center(
            child: SizedBox(
              height: 100,
              child: Lottie.asset("lib/assets/animations/loading.json"),
            ),
          );
        },
      );

      // Start Google sign-in process
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null; // The user canceled the sign-in process
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

      // Close the loading dialog
      
      // Send ID token to the backend
      final idToken = await userCredential.user?.getIdToken();
      if (idToken != null) {
        await sendIdTokenToBackend(idToken);
      }
      if (dialogContext != null) {
        Navigator.pop(dialogContext!); // Close the loading dialog
      }

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
        return HomePage();
      }));
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
      print('An error occurred: $e');
    }
    return null;
  }

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

      if (response.statusCode == 200) {
        // Parse the response to get the token from the backend
        final token = json.decode(response.body)['token'];

        // Store the token securely
        await secureStorage.write(key: 'auth_token', value: token);
        print('Token stored successfully');
      } else {
        print('Failed to authenticate with backend: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending ID token to backend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    Expanded(
                        child: Container(height: 1, color: Colors.grey[600])),
                    const SizedBox(width: 2),
                    const Text("Continue with"),
                    const SizedBox(width: 2),
                    Expanded(
                        child: Container(height: 1, color: Colors.grey[600])),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: signInWithGoogle,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.shade300,
                  ),
                  child:
                      Image.asset("lib/assets/images/google.png", height: 30),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

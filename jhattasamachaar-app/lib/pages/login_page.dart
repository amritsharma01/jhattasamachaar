// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jhattasamachaar/pages/home_page.dart';
import 'package:lottie/lottie.dart';
import 'package:google_sign_in/google_sign_in.dart';

//shoukd be stateful widget
class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Future<UserCredential?> signInWithGoogle() async {
    BuildContext? dialogContext;

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null;
      }

      // Show loading dialog
      showDialog(
          barrierColor: Colors.black54,
          context: context,
          barrierDismissible:
              false, // Prevents the dialog from closing by touching outside
          builder: (BuildContext ctx) {
            dialogContext = ctx;
            return Center(
              child: SizedBox(
                height: 100,
                child: Lottie.asset("lib/assets/animations/loading.json"),
              ),
            );
          });

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Close the loading dialog first
      if (dialogContext != null) {
        Navigator.pop(
            dialogContext!); // Use the stored dialogContext to close the dialog
      }

      // Check if the widget is still mounted before using context
     

      return userCredential;
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
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      body: Center(
        //cloumn wrapped with center widget
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, //to align column in center vertically
            children: [
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    const Text("Continue with"),
                    const SizedBox(
                      width: 2,
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: signInWithGoogle,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade300),
                  child: Image.asset(
                    "lib/assets/images/google.png",
                    height: 30,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

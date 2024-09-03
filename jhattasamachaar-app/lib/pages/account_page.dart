import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  User? user;
  String name = 'User';
  @override
  void initState() {
    super.initState();
    // Get the current user and set the username
    user = FirebaseAuth.instance.currentUser;
    if (user != null && user!.displayName != null) {
      setState(() {
        name = user!.displayName!;
      });
    }
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

                // Perform sign out
                await GoogleSignIn().signOut();
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Container(
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue,
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
                  color: Colors.blue,
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
        title: Text(name),
        backgroundColor: Colors.grey.shade300,
        actions: [
          GestureDetector(
            onTap: signOut,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.green,
                ),
                height: 40,
                width: 110,
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "LogOut",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Icons.logout_sharp,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
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

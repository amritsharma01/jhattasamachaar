import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jhattasamachar/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // compulsory for firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginPage(),
  ));
}

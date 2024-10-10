import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jhattasamachaar/firebase_options.dart';
import 'package:jhattasamachaar/pages/home_page.dart';
import 'package:jhattasamachaar/pages/login_page.dart';
import 'package:jhattasamachaar/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // compulsory for Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize secure storage
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String? token = await secureStorage.read(key: 'auth_token');
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        return ThemeProvider();
      },
      child: MyApp(token: token),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? token;
  const MyApp({Key? key, this.token}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Provider.of<ThemeProvider>(context).themeData,
      debugShowCheckedModeBanner: false,
      home: token != null ? const HomePage() : const Login(),
    );
  }
}

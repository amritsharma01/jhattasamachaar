import 'package:flutter/material.dart';
import 'package:jhattasamachaar/pages/login_page.dart';

class TokenNotFound extends StatelessWidget {
  const TokenNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: const Text('Error'),
      content: const Text('Token missing or expired, please login again'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) {
                return const Login();
              }),
              (Route<dynamic> route) {
                return false;
              },
            );
          },
          child: const Text('Login'),
        ),
      ],
    );
  }
}

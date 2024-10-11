import 'package:flutter/material.dart';
import 'package:jhattasamachaar/pages/login_page.dart';

class TokenNotFound extends StatelessWidget {
  const TokenNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title:  Text(
        'Error',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Theme.of(context).dialogTheme.titleTextStyle!.color,
        ),
      ),
      content:  Text(
        'Token missing or expired, please login again',
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).dialogTheme.contentTextStyle!.color,
        ),
      ),
      actions: [
        ElevatedButton(
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
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).buttonTheme.colorScheme!.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(
              "Ok",
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
  }
}

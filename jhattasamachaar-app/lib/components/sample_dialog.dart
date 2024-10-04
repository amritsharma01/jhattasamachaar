import 'package:flutter/material.dart';

class SampleDialog extends StatelessWidget {
  final String title;
  final String description;
  final void Function() perform;
  final String buttonText;
  const SampleDialog(
      {Key? key,
      required this.title,
      required this.description,
      required this.perform,
      required this.buttonText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.black87,
        ),
      ),
      content: Text(
        description,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
      ),
      actions: [
        // No Button

        // Yes Button
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            perform();
            // Action for "Yes" will be handled outside
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(
              buttonText,
              style: const TextStyle(
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

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
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        title,
        style:  TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color:  Theme.of(context).dialogTheme.titleTextStyle!.color,
        ),
      ),
      content: Text(
        description,
        style:  TextStyle(
          fontSize: 16,
          color:  Theme.of(context).dialogTheme.contentTextStyle!.color,
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
            backgroundColor: Theme.of(context).buttonTheme.colorScheme!.primary,
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

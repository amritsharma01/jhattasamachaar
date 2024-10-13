import 'package:flutter/material.dart';

class EverythingCaughtUpMessage extends StatelessWidget {
  const EverythingCaughtUpMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 13),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.onSecondary, width: 1),
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 40,
              color: Colors.green,
            ),
            const SizedBox(width: 10),
            Text(
              "Everything caught up!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

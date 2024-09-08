import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SettingsTile extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final icon;
  final String name;
  final Color color;
  void Function()? ontap;
  SettingsTile(
      {super.key,
      required this.icon,
      required this.name,
      required this.color,
      required this.ontap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: ontap,
        child: Container(
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(name,
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

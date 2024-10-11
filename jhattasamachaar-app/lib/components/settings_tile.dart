// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final icon;
  final String name;
  
  final void Function()? ontap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.name,
    
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: ontap,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).listTileTheme.tileColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: Theme.of(context).listTileTheme.iconColor,
                ),
                const SizedBox(width: 15),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 17,
                    color: Theme.of(context).listTileTheme.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Theme.of(context).listTileTheme.iconColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:flutter/material.dart';

import 'package:jhattasamachaar/pages/news_page.dart';
import 'package:jhattasamachaar/pages/account_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int i = 0;
  void func(index) {
    setState(() {
      i = index;
    });
  }

  final List<Widget> page = [
    const NewsPage(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: page[i],
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        onTap: func,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        backgroundColor: Colors.transparent, // Keep the background transparent
        color: Colors.grey.shade300, // Light grey for a soft background
        buttonBackgroundColor:
            Colors.blue.shade600, // Slightly darker green for the active button
        letIndexChange: (index) => true,
        items: [
          Icon(
            Icons.home,
            size: 33,
            color: i == 0
                ? Colors.white
                : Colors.grey.shade700, // Active icon white, inactive grey
          ),
          Icon(
            Icons.person,
            size: 33,
            color: i == 1
                ? Colors.white
                : Colors.grey.shade700, // Active icon white, inactive grey
          ),
        ],
      ),
    );
  }
}

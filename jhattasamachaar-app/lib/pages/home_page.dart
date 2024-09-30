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
          height: 60,
          onTap: func,
          animationCurve: Curves.linearToEaseOut,
          backgroundColor: Colors.grey.shade100,
          color: Colors.grey.shade300,
          buttonBackgroundColor: Colors.green.shade200,
          items: const [
            Icon(
              Icons.home,
              size: 34,
            ),
            Icon(
              Icons.person,
              size: 34,
            ),
          ]),
    );
  }
}

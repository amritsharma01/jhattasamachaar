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
        color: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor!,
        buttonBackgroundColor:
           Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        letIndexChange: (index) => true,
        items: [
          Icon(
            Icons.home,
            size: i == 0
                ? Theme.of(context).bottomNavigationBarTheme.selectedIconTheme!.size!
                :  Theme.of(context)
                    .bottomNavigationBarTheme
                    .unselectedIconTheme!
                    .size!,
            color: i == 0
                ? Theme.of(context).bottomNavigationBarTheme.selectedIconTheme!.color!
                : Theme.of(context)
                    .bottomNavigationBarTheme
                  .unselectedIconTheme!.color!, // Active icon white, inactive grey
          ),
          Icon(
            Icons.person,
              size: i == 1
                ? Theme.of(context)
                    .bottomNavigationBarTheme
                    .selectedIconTheme!
                    .size!
                : Theme.of(context)
                    .bottomNavigationBarTheme
                    .unselectedIconTheme!
                    .size!,
            color: i == 1
                   ? Theme.of(context)
                    .bottomNavigationBarTheme
                    .selectedIconTheme!
                    .color!
                : Theme.of(context)
                    .bottomNavigationBarTheme
                    .unselectedIconTheme!
                    .color!, // Active icon white, inactive grey
          ),
        ],
      ),
     
    );
  }
}

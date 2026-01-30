import 'package:flutter/material.dart';
import 'package:voxa/screens/screen_login.dart';

class MainScreen extends StatefulWidget {
  static final GlobalKey menuKey = GlobalKey();
  const MainScreen({super.key});

  // static final GlobalKey menuKey = GlobalKey(); // 🔥 static access

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: MainScreen.menuKey,
          icon: const Icon(Icons.menu),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AnimatedLoginScreen()),
            );
          },
        ),
      ),
    );
  }
}

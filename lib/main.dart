import 'package:flutter/material.dart';
// import 'package:voxa/screens/screen_home.dart';
import 'package:voxa/screens/screen_login.dart';

void main() {
  runApp(myApp());
}

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedLoginScreen(),
    );
  }
}

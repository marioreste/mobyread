import 'package:flutter/material.dart';
import 'screens/first_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MobyRead',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF04122B),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF021025)),
        brightness: Brightness.dark,
      ),
      home: const FirstScreen(),
    );
  }
}


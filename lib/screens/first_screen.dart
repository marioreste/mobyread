import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'reading_screen.dart';
import 'read_screen.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({Key? key}) : super(key: key);

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  
  var activeScreen = 'home';
  void switchNewScreen(String screenName) {
    setState(() {
      activeScreen = screenName;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    Widget screenWidget = HomeScreen(switchNewScreen);

    if (activeScreen == 'reading') {
      screenWidget = ReadingScreen(); 
    } else if (activeScreen == 'read') {
      screenWidget = ReadScreen();
    }
    
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4B0088),
                  Color.fromARGB(255, 45, 0, 81),
                ],
              ),
            ),
          child: screenWidget,
          ),
        ),
      ),
    );
  }
}

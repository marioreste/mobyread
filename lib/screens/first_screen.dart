import 'package:flutter/material.dart';

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
    Widget screenWidget = HomeScreen(); //@TODO HomeScreen

    if (activeScreen == 'reading') {
      screenWidget = ReadingScreen(); //@TODO ReadingScreen
    } else if (activeScreen == 'read') {
      screenWidget = ReadScreen(); //@TODO ReadScreen
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

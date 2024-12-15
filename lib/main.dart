import 'package:flutter/material.dart';
import 'package:picdb/screens/home.dart';
import 'package:picdb/screens/onboarding.dart';
import 'package:picdb/screens/splash.dart';

void main() {
  runApp(PicDB());
}

class PicDB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),  // Replace with your home screen widget
      // Alternatively, use:
      routes: {
        "/home": (context) => HomeScreen(),
        "/onboarding": (context) => OnboardingScreen(),
      },
    );
  }
}

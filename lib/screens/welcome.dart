import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../widgets/check_connection.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for the animation to finish (e.g., after 3 seconds)
    Future.delayed(const Duration(seconds: 7), () {
      // Navigate to the home screen after the splash screen
      Navigator.pushReplacementNamed(context, '/upload');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidget(
      child: Scaffold(
        backgroundColor: Colors.white, // Background color of splash screen
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column (
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    './assets/lottie/welcome.json',  // Replace with your animation file path
                    // width: 200,  // Optional: Size of the animation
                    height: 150,  // Optional: Size of the animation
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Made with ❤️ by AvianInTek",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontFamily: 'Vonique',
                    ),
                  ),
                ]
            ),
          ),
        ),
      ),
    );
  }
}
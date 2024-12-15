import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for the animation to finish (e.g., after 3 seconds)
    Future.delayed(const Duration(seconds: 8), () {
      // Navigate to the home screen after the splash screen
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                "Made with ❤️ by Akkil",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}
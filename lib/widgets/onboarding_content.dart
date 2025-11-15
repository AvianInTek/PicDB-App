import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnboardingContent extends StatelessWidget {
  final String title;
  final String description;
  final String animation;

  const OnboardingContent({
    super.key,
    required this.title,
    required this.description,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          animation,
          height: 300,
        ),
        const SizedBox(height: 30),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

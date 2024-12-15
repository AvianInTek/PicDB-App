import 'package:flutter/material.dart';
import '../models/onboarding_step.dart';

class OnboardingContent extends StatelessWidget {
  final OnboardingStep step;

  const OnboardingContent({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            step.image,
            width: 350,
            height: 350,
          ),
          SizedBox(height: 20),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Text(
            step.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

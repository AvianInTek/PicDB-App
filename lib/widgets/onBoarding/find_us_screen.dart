import 'package:flutter/material.dart';
import 'package:picdb/models/color_palettes.dart';
import 'package:picdb/models/onboarding_step.dart';

class FindUsScreen extends StatelessWidget {
  final int selectedFindUs;
  final Function(int) onSelectFindUs;
  final String color;

  const FindUsScreen({required this.selectedFindUs, required this.onSelectFindUs, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            "https://via.placeholder.com/350",
            width: 350,
            height: 350,
          ),
          const SizedBox(height: 20),
          const Text(
            "How did you find me?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10, // Horizontal space between items
            runSpacing: 10, // Vertical space between rows
            children: [
              for (int i = 0; i < OnboardingHowTo.FindUs.length; i++)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedFindUs == i
                        ? HexColor.fromHex(color)
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    side: BorderSide(color: Colors.black),
                  ),
                  onPressed: () => onSelectFindUs(i),
                  child: Text(
                    OnboardingHowTo.FindUs[i],
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}

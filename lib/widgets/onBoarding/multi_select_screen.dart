import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:picdb/models/color_palettes.dart';
import 'package:picdb/models/onboarding_step.dart';

class MultiSelectScreen extends StatelessWidget {
  final List<int> selectedOptions;
  final Function(int) onToggleOption;
  final String color;

  const MultiSelectScreen({
    required this.selectedOptions,
    required this.onToggleOption,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            './assets/lottie/onboarding_purpose.json',
            width: 350,
            fit: BoxFit.fill,
          ),
          const SizedBox(height: 20),
          const Text(
            "What purpose are you gonna use me?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(OnboardingPurpose.ofUsing.length, (index) {
              final isSelected = selectedOptions.contains(index);
              return GestureDetector(
                onTap: () => onToggleOption(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? HexColor.fromHex(color) : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Text(
                    OnboardingPurpose.ofUsing[index],
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}


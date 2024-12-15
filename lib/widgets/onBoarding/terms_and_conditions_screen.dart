import 'package:flutter/material.dart';
import 'package:picdb/models/onboarding_step.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  final bool termsAccepted;
  final ValueChanged<bool?> onAcceptTerms;
  const TermsAndConditionsScreen({required this.termsAccepted, required this.onAcceptTerms, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(  // Add this to allow scrolling
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Terms and Conditions',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Loop through the terms and conditions and build Text widgets
                  for (var entry in OnboardingTnC.terms.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          entry.key != "0" ? Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ) : Container(),
                          const SizedBox(height: 8),

                          // Check if the value is a String
                          if (entry.value is String)
                            Text(
                              entry.value as String,  // cast to String
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),

                          // Check if the value is a List<String>
                          if (entry.value is List)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: (entry.value as List<String>).map(
                                    (item) => Row(
                                  children: [
                                    Icon(Icons.brightness_1, size: 8, color: Colors.black),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ).toList(),
                            ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: termsAccepted,
                  onChanged: onAcceptTerms,
                ),
                const Text('I accept the terms and conditions', style: TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

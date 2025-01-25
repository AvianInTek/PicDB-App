
import 'package:flutter/material.dart';
import 'package:picdb/models/color_palettes.dart';
import 'package:picdb/widgets/onBoarding/find_us_screen.dart';
import 'package:picdb/widgets/onBoarding/multi_select_screen.dart';
import 'package:picdb/widgets/onBoarding/palette_screen.dart';
import 'package:picdb/widgets/onBoarding/terms_and_conditions_screen.dart';
import 'package:picdb/widgets/onboarding_content.dart';
import 'package:picdb/models/onboarding_step.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/check_connection.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

@override
_OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  int selectedFindUs = 8;
  String selectedColor = Palette.beige;
  List<int> selectedOptions = [];
  bool termsAccepted = false;
  String error = '';
  late SharedPreferences prefs;
  final List<OnboardingStep> onboardingContent = [
    OnboardingStep(
      lottie: './assets/lottie/onboarding_welcome.json',
      title: 'Welcome to PicDB.\nYour free storage provider.',
      subtitle: 'Our mission is to make image storage easy and free to access for everyone without any charges.',
    ),
  ];

  void initState() {
    super.initState();
    initPrefs();
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }


  finish() {
      if (_currentIndex < onboardingContent.length + 3) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (_currentIndex == onboardingContent.length + 3 && !termsAccepted) {
        error = 'Please accept the terms and conditions to continue.';
      } else if (_currentIndex == onboardingContent.length + 3 && termsAccepted) {
        if (selectedColor.isNotEmpty && selectedOptions.isNotEmpty) {
          prefs.setString('color', selectedColor);

          Navigator.pushReplacementNamed(context, '/welcome');
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidget(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: _currentIndex > 0 ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ) : null,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  ...onboardingContent.map((step) =>
                      OnboardingContent(step: step)),
                  ColorScreen(
                    selectedColor: selectedColor,
                    onSelectColor: (option) {
                      setState(() {
                        selectedColor = option;
                      });
                    },
                  ),
                  FindUsScreen(
                    selectedFindUs: selectedFindUs,
                    color: selectedColor,
                    onSelectFindUs: (option) {
                      setState(() {
                        selectedFindUs = option;
                      });
                    },
                  ),
                  MultiSelectScreen(
                    color: selectedColor,
                    selectedOptions: selectedOptions,
                    onToggleOption: (option) {
                      setState(() {
                        if (selectedOptions.contains(option)) {
                          selectedOptions.remove(option);
                        } else {
                          selectedOptions.add(option);
                        }
                      });
                    },
                  ),
                  TermsAndConditionsScreen(
                    termsAccepted: termsAccepted,
                    onAcceptTerms: (value) {
                      setState(() {
                        termsAccepted = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 10.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: finish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentIndex ==
                          onboardingContent.length + 3 && !termsAccepted
                          ? Colors.grey
                          : Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentIndex == onboardingContent.length + 3
                          ? 'Start'
                          : 'Next',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // if (_currentIndex < onboardingContent.length)
                  //   TextButton(
                  //     onPressed: () {},
                  //     child: Text(
                  //       "I don’t have a plan",
                  //       style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  //     ),
                  //   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
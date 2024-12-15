// import 'package:flutter/material.dart';
// import 'package:picdb/progress/progress.dart';
//
// class OnboardingScreen extends StatefulWidget {
//   @override
//   _OnboardingScreenState createState() => _OnboardingScreenState();
// }
//
// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   int _currentIndex = 0;
//
//   final List<Map<String, String>> onboardingContent = [
//     {
//       'image': 'https://via.placeholder.com/350', // Replace with actual image URL or asset
//       'title': 'Track your progress.\nReward your wins.',
//       'subtitle': 'Tracking keeps you focused, inspired and determined. Set your workout target to keep yourself fired up and on-track.'
//     },
//     {
//       'image': 'https://via.placeholder.com/350', // Replace with actual image URL or asset
//       'title': 'Celebrate milestones.\nStay consistent.',
//       'subtitle': 'Achieving goals is exciting. Stay consistent by rewarding yourself along the way.'
//     },
//     {
//       'image': 'https://via.placeholder.com/350', // Replace with actual image URL or asset
//       'title': 'Build healthy habits.\nSustain long-term results.',
//       'subtitle': 'Create a routine that supports your goals, turning small changes into lasting habits.'
//     },
//     {
//       'image': 'https://via.placeholder.com/350', // Replace with actual image URL or asset
//       'title': 'Your journey starts here.\nLet’s begin!',
//       'subtitle': 'Every step forward counts. Start today to reach your ultimate goals.'
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             if (_currentIndex > 0) {
//               _pageController.previousPage(
//                 duration: Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//               );
//             } else {
//               Navigator.pop(context);
//             }
//           },
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: PageView.builder(
//               controller: _pageController,
//               onPageChanged: (index) {
//                 setState(() {
//                   _currentIndex = index;
//                 });
//               },
//               itemCount: onboardingContent.length,
//               itemBuilder: (context, index) {
//                 final content = onboardingContent[index];
//                 return Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Image.network(
//                         content['image']!,
//                         width: 350,
//                         height: 350,
//                       ),
//                       SizedBox(height: 20),
//                       Text(
//                         content['title']!,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Text(
//                         content['subtitle']!,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey[700],
//                         ),
//                       ),
//                       SizedBox(height: 30),
//                       InfoBar(totalIndex: onboardingContent.length, activeIndex: index),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
//             child: Column(
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_currentIndex < onboardingContent.length - 1) {
//                       _pageController.nextPage(
//                         duration: Duration(milliseconds: 300),
//                         curve: Curves.easeInOut,
//                       );
//                     } else {
//                       // Navigate to the next screen
//                       Navigator.pushReplacementNamed(context, '/home');
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   child: Text(
//                     _currentIndex == onboardingContent.length - 1 ? 'Start' : 'Next',
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 TextButton(
//                   onPressed: () {},
//                   child: Text(
//                     "I don’t have a plan",
//                     style: TextStyle(color: Colors.grey[700], fontSize: 16),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//
// import 'package:flutter/material.dart';
// import '../widgets/onboarding_content.dart';
// import '../widgets/info_bar.dart';
// import '../models/onboarding_step.dart';
//
// class OnboardingScreen extends StatefulWidget {
//   @override
//   _OnboardingScreenState createState() => _OnboardingScreenState();
// }
//
// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   int _currentIndex = 0;
//
//   final List<OnboardingStep> onboardingContent = [
//     OnboardingStep(
//       image: 'https://via.placeholder.com/350',
//       title: 'Track your progress.\nReward your wins.',
//       subtitle: 'Tracking keeps you focused, inspired and determined. Set your workout target to keep yourself fired up and on-track.',
//     ),
//     OnboardingStep(
//       image: 'https://via.placeholder.com/350',
//       title: 'Celebrate milestones.\nStay consistent.',
//       subtitle: 'Achieving goals is exciting. Stay consistent by rewarding yourself along the way.',
//     ),
//     OnboardingStep(
//       image: 'https://via.placeholder.com/350',
//       title: 'Build healthy habits.\nSustain long-term results.',
//       subtitle: 'Create a routine that supports your goals, turning small changes into lasting habits.',
//     ),
//     OnboardingStep(
//       image: 'https://via.placeholder.com/350',
//       title: 'Your journey starts here.\nLet’s begin!',
//       subtitle: 'Every step forward counts. Start today to reach your ultimate goals.',
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             if (_currentIndex > 0) {
//               _pageController.previousPage(
//                 duration: Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//               );
//             } else {
//               Navigator.pop(context);
//             }
//           },
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: PageView.builder(
//               controller: _pageController,
//               onPageChanged: (index) {
//                 setState(() {
//                   _currentIndex = index;
//                 });
//               },
//               itemCount: onboardingContent.length,
//               itemBuilder: (context, index) {
//                 return OnboardingContent(step: onboardingContent[index]);
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
//             child: Column(
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_currentIndex < onboardingContent.length - 1) {
//                       _pageController.nextPage(
//                         duration: Duration(milliseconds: 300),
//                         curve: Curves.easeInOut,
//                       );
//                     } else {
//                       Navigator.pushReplacementNamed(context, '/home');
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   child: Text(
//                     _currentIndex == onboardingContent.length - 1 ? 'Start' : 'Next',
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 TextButton(
//                   onPressed: () {},
//                   child: Text(
//                     "I don’t have a plan",
//                     style: TextStyle(color: Colors.grey[700], fontSize: 16),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:picdb/models/color_palettes.dart';
import 'package:picdb/widgets/onBoarding/find_us_screen.dart';
import 'package:picdb/widgets/onBoarding/multi_select_screen.dart';
import 'package:picdb/widgets/onBoarding/palette_screen.dart';
import 'package:picdb/widgets/onBoarding/terms_and_conditions_screen.dart';
import 'package:picdb/widgets/onboarding_content.dart';
import 'package:picdb/models/onboarding_step.dart';


class OnboardingScreen extends StatefulWidget {
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

  final List<OnboardingStep> onboardingContent = [
    OnboardingStep(
      image: 'https://via.placeholder.com/350',
      title: 'Welcome to PicDB.\nYour free storage provider.',
      subtitle: 'Our mission is to make image storage easy and free to access for everyone without any charges.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  onPressed: () {
                    if (_currentIndex < onboardingContent.length + 3) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else if (_currentIndex == onboardingContent.length + 3 &&
                        termsAccepted) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
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
    );
  }
}
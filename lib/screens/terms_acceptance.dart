import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAcceptanceScreen extends StatefulWidget {
  const TermsAcceptanceScreen({super.key});

  @override
  State<TermsAcceptanceScreen> createState() => _TermsAcceptanceScreenState();
}

class _TermsAcceptanceScreenState extends State<TermsAcceptanceScreen> {
  bool termsAccepted = false;
  bool privacyAccepted = false;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  void _handleContinue() async {
    if (termsAccepted && privacyAccepted) {
      await prefs.setBool("accepted", true);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  void _handleExit() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to PicDB',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Before you continue, please read and accept our Terms of Service and Privacy Policy.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),
                CheckboxListTile(
                  title: Row(
                    children: [
                      const Text('I accept the '),
                      GestureDetector(
                        onTap: () => _launchURL('https://picdb.arkynox.com/policy/terms-of-service'),
                        child: const Text(
                          'Terms of Service',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  value: termsAccepted,
                  onChanged: (bool? value) {
                    setState(() {
                      termsAccepted = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Row(
                    children: [
                      const Text('I accept the '),
                      GestureDetector(
                        onTap: () => _launchURL('https://picdb.arkynox.com/policy/privacy'),
                        child: const Text(
                          'Privacy Policy',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  value: privacyAccepted,
                  onChanged: (bool? value) {
                    setState(() {
                      privacyAccepted = value ?? false;
                    });
                  },
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _handleExit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Exit App'),
                    ),
                    ElevatedButton(
                      onPressed: termsAccepted && privacyAccepted ? _handleContinue : null,
                      child: const Text('Continue'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

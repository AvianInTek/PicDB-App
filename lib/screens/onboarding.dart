import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../widgets/onboarding_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool termsAccepted = false;
  bool privacyAccepted = false;
  late SharedPreferences prefs;

  // Username input handling
  final TextEditingController _usernameController = TextEditingController();
  bool _isUsernameValid = false;
  bool _isSubmitting = false;
  String? _usernameError;
  final APIService _apiService = APIService();
  bool _hasUsername = false;

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Welcome to PicDB',
      'description': 'Your secure and efficient image management solution',
      'animation': 'assets/lottie/onboarding_welcome.json',
    },
    {
      'title': 'Easy Image Upload',
      'description': 'Upload and manage your images with just a few taps',
      'animation': 'assets/lottie/upload.json',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  void _initPrefs() async {
    prefs = await SharedPreferences.getInstance();

    // Check if username and uid already exist in SharedPreferences
    final String? username = prefs.getString('username');
    final String? uid = prefs.getString('uid');

    setState(() {
      _hasUsername = username != null && uid != null;
      if (_hasUsername) {
        _usernameController.text = username!;
      }
    });
  }

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  void _handleContinue() async {
    // Dismiss keyboard first
    FocusScope.of(context).unfocus();

    // If we're on the last page (policy page)
    if (_currentPage == onboardingData.length + 1) {
      if (termsAccepted && privacyAccepted) {
        await prefs.setBool("accepted", true);
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/upload');
        }
      }
    }
    // If we're on the username page
    else if (_currentPage == onboardingData.length) {
      if (_hasUsername) {
        // Username already exists, proceed to policy page
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        // Username doesn't exist yet, validate and submit
        if (_isUsernameValid) {
          final success = await _submitUsername();
          if (success) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          }
        } else {
          // Validate the current input to show errors if needed
          setState(() {
            _validateUsername(_usernameController.text);
          });
        }
      }
    }
    // Otherwise, we're on a regular onboarding page
    else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _validateUsername(String value) {
    if (value.isEmpty) {
      _isUsernameValid = false;
      _usernameError = 'Username cannot be empty';
    } else if (value.length < 3) {
      _isUsernameValid = false;
      _usernameError = 'Username must be at least 3 characters';
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      _isUsernameValid = false;
      _usernameError = 'Only letters, numbers, and underscores allowed';
    } else {
      _isUsernameValid = true;
      _usernameError = null;
    }
  }

  Future<bool> _submitUsername() async {
    if (!_isUsernameValid) return false;

    setState(() {
      _isSubmitting = true;
    });

    final username = _usernameController.text.trim();
    final result = await APIService.setUsernameAPI(username);

    setState(() {
      _isSubmitting = false;
    });

    if (result['success'] == true && result['id'] != null) {
      // Store username and uid in SharedPreferences
      await prefs.setString('username', username);
      await prefs.setString('uid', result['id']);
      return true;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to set username'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return false;
  }

  Widget _buildUsernameInputPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 200, // Allow scrolling but ensure content fills screen
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Your Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Lottie.asset(
                  "assets/lottie/onboarding_found.json",
                  height: 180,  // Reduced height further to avoid overflow
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose a username to identify yourself:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter a username',
                  errorText: _usernameError,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  prefixIcon: const Icon(Icons.person),
                ),
                onChanged: (value) {
                  setState(() {
                    _validateUsername(value);
                  });
                },
              ),
              const SizedBox(height: 8),
              if (_isSubmitting)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Almost there!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                "assets/lottie/policy.json",
                height: 300,
              ),
              ]
          ),
          const Text(
            'Please review and accept our policies to continue:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            child: Column(
                children: [
                  CheckboxListTile(
                    title: Row(
                      children: [
                        const Text(
                          'I accept the ',
                          style: TextStyle(
                            fontSize: 15,
                          ),),
                        GestureDetector(
                          onTap: () => _launchURL('https://picdb.arkynox.com/policy/mobile/terms-of-service'),
                          child: const Text(
                            'Terms of Service',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
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
                  const Divider(),
                  CheckboxListTile(
                    title: Row(
                      children: [
                        const Text(
                          'I accept the ',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _launchURL('https://picdb.arkynox.com/policy/mobile/privacy'),
                          child: const Text(
                            'Privacy Policy',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
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
                ],
              ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Total number of pages (onboarding content + username page + policy page)
    final totalPages = onboardingData.length + 2;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  // Close keyboard if it's open when changing pages
                  FocusScope.of(context).unfocus();

                  setState(() {
                    _currentPage = page;
                  });
                },
                physics: const NeverScrollableScrollPhysics(), // Disable sliding between pages
                children: [
                  ...onboardingData.map(
                    (content) => OnboardingContent(
                      title: content['title']!,
                      description: content['description']!,
                      animation: content['animation']!,
                    ),
                  ),
                  _buildUsernameInputPage(),
                  _buildPolicyPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      totalPages,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                        // On policy page, only enable if accepted both policies
                        _currentPage == onboardingData.length + 1
                          ? (termsAccepted && privacyAccepted)
                              ? _handleContinue
                              : null
                        // On username page, only enable if username valid or already exists
                        : _currentPage == onboardingData.length
                          ? (_isUsernameValid || _hasUsername) && !_isSubmitting
                              ? _handleContinue
                              : null
                        // On regular onboarding pages, always enable
                        : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _currentPage == onboardingData.length + 1 ? 'Get Started' : 'Next',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

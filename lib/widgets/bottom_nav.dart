import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/dashboard.dart';
import '../screens/group_list_screen.dart';
import '../screens/upload.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
  });

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            gap: 8,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(milliseconds: 400), // Smooth transition duration
            curve: Curves.easeInOut, // Smooth animation curve
            selectedIndex: selectedIndex,
            onTabChange: (index) async {
              if (index == 3) {
                // Support tab
                await _launchUrl('https://desk.arkynox.com/');
              } else if (index != selectedIndex) {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return FadeTransition(
                        opacity: animation,
                        child: _getScreen(index),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              }
            },
            tabs: const [
              GButton(
                icon: Icons.upload,
                text: 'Upload',
                iconSize: 24,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              GButton(
                icon: Icons.dashboard_outlined,
                text: 'Dashboard',
                iconSize: 24,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              GButton(
                icon: Icons.group,
                text: 'Group Room',
                iconSize: 24,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              GButton(
                icon: Icons.support_agent,
                text: 'Support',
                iconSize: 24,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const UploadImage();
      case 1:
        return const DashboardScreen();
      case 2:
        return const GroupListScreen();
      default:
        return const UploadImage();
    }
  }
}

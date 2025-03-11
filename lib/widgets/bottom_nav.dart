


import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
        child: GNav(
          backgroundColor: Colors.black,
          color: Colors.white,
          activeColor: Colors.white,
          tabBackgroundColor: Colors.grey.shade800,
          gap: 8,
          padding: const EdgeInsets.all(8),
          selectedIndex: selectedIndex,
          onTabChange: (index) {
            if (index == 0) {
              Navigator.pushReplacementNamed(context, '/upload');
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, '/dashboard');
            } else if (index == 2) {
              launch(Uri.parse("https://heimancreatiin.t.me").toString()).then((success) {
                if (!success) {
                  throw 'Could not launch https://heimancreatiin.t.me';
                }
              });
            }
          },
          tabs: const [
            GButton(
              icon: Icons.upload,
              text: 'Upload',
            ),
            GButton(
              icon: Icons.dashboard,
              text: 'Dashboard',
            ),
            GButton(
              icon: Icons.telegram,
              text: 'Support',
            ),
          ],
        ),
      ),
    );
  }
}
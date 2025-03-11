import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/notify_service.dart';
import '../widgets/check_connection.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SharedPreferences prefs;
  late bool accepted;
  late List<String> images;
  @override
  void initState() {
    super.initState();
    initPrefs();
    Future.delayed(const Duration(seconds: 2), () {
      initAccepted();
      initNotification();
    });
    Future.delayed(const Duration(seconds: 8), () {
      Navigator.pushReplacementNamed(context, accepted ? '/upload' : '/onboarding');
    });
  }

  void initAccepted() async {
    accepted = prefs.getBool("accepted") ?? false;
    if (!accepted) {
      await prefs.setBool("accepted", false);
    }
  }

  void initImages() async {
    images = prefs.getStringList("images") ?? [];
    if (images.isEmpty) {
      await prefs.setStringList("images", []);
    }
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void initNotification() {
    String _recent_notify_id = prefs.getString('recent_notify') ?? '';
    APIService().fetchNotify().then((notification) {
      if (notification['success'] == true) {
        if (notification['id'] != _recent_notify_id) {
          prefs.setString('message_id', notification['id']);
          NotifyService().showNotification(
            title: notification['title'],
            body: notification['body'],
          );
          prefs.setString('recent_notify', notification['id']);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidget(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column (
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/logo/app_icon.png"),
                const Text(
                  "PicDB",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.black,
                    fontFamily: 'Vonique',
                  ),
                ),
                const Text(
                  "Made with ❤️ by AvianInTek",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'Vonique',
                  ),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}
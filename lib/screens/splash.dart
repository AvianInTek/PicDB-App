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
  final NotifyService _notifyService = NotifyService();

  @override
  void initState() {
    super.initState();
    initPrefs();
    _initializeNotifications();
    Future.delayed(const Duration(seconds: 2), () {
      initAccepted();
      initNotification();
    });
    Future.delayed(const Duration(seconds: 8), () {
      if (accepted) {
        Navigator.pushReplacementNamed(context, '/upload');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  Future<void> _initializeNotifications() async {
    await _notifyService.initNotification();
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

  void initNotification() async {
    String recentNotifyId = prefs.getString('recent_notify') ?? '';
    try {
      final notification = await APIService().fetchNotify();
      if (notification['success'] == true) {
        final notifications = notification['notifications'] as List;
        for (var notify in notifications) {
          if (notify['_id'] != recentNotifyId) {
            await _notifyService.showNotification(
              title: notify['title'],
              body: notify['body'],
              id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            );
            await prefs.setString('recent_notify', notify['_id']);
          }
        }
      }
    } catch (e) {
      print('Error showing notification: $e');
    }
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
                  "Made with ❤️ by Arkynox",
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
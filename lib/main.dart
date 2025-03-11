import 'package:flutter/material.dart';
import 'package:picdb/screens/dashboard.dart';
import 'package:picdb/screens/onboarding.dart';
import 'package:picdb/screens/payment.dart';
import 'package:picdb/screens/splash.dart';
import 'package:picdb/screens/upload.dart';
import 'package:picdb/screens/welcome.dart';
import 'package:picdb/services/notify_service.dart';
import 'package:picdb/widgets/check_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  NotifyService().initNotification();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  StatelessElement createElement() {
    return super.createElement();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home:  const SplashScreen(),
      routes: {
        "/splash": (context) => const SplashScreen(),
        "/onboarding": (context) => const OnboardingScreen(),
        "/welcome": (context) => const WelcomeScreen(),
        "/upload": (context) => const UploadImage(),
        "/dashboard": (context) => const DashboardScreen(),
        "/payment": (context) => const PaymentScreen()
      },
    );
  }
}
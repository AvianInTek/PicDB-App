import 'dart:async';
import 'package:flutter/material.dart';
import '../services/internet_checker.dart';

class ConnectivityWidget extends StatefulWidget {
  final Widget child; // The widget to display when connected

  const ConnectivityWidget({Key? key, required this.child}) : super(key: key);

  @override
  _ConnectivityWidgetState createState() => _ConnectivityWidgetState();
}

class _ConnectivityWidgetState extends State<ConnectivityWidget> {
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isConnected = InternetChecker().check(_isConnected) as bool;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Visibility(
            visible: _isConnected,
            child: widget.child, // Display the child widget when connected
          ),
          if (!_isConnected)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Check your internet",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
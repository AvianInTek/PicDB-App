import 'dart:async';
import 'dart:io';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetChecker {
  bool check(_isConnected) {
    var conn = _isConnected;
    StreamSubscription? _internetConnectionStreamSubscription;
    _internetConnectionStreamSubscription = InternetConnection().onStatusChange.listen((status) async {
      switch (status) {
        case InternetStatus.connected:
          try {
            final result = await InternetAddress.lookup('https://google.com');
            if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
              conn = true;
            }
          } on SocketException catch (_) {
            conn = false;
          }
          break;
        case InternetStatus.disconnected:
          conn = false;
          break;
        default:
          conn = false;
          break;
      }
    });
    return conn;
  }
}
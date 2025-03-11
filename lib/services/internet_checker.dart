import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetChecker {
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Timer? _timer;

  InternetChecker() {
    _startChecking();
  }

  void _startChecking() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      bool isConnected = await _hasInternet();
      _controller.add(isConnected); // Emit new status
    });
  }

  /// Checks if device has internet access by pinging Google & API.
  Future<bool> _hasInternet() async {
    try {
      // Step 1: Check basic internet connectivity (Google DNS)
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) return false;

      // Step 2: Verify API endpoint
      final response = await http.get(Uri.parse('https://www.heggadevahini.com/api/v1/news'));
      if (response.statusCode == 200) {
        return response.body.contains('"success":true');
      }
    } on SocketException {
      return false;
    } catch (e) {
      return false;
    }
    return false;
  }

  Stream<bool> get connectionStream => _controller.stream;

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}

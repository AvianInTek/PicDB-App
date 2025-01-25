import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;


class APIService {
  static const String _apiUrl = 'https://picdb.avianintek.workers.dev';
  static const String _helperUrl = 'https://helper-picdb.avianintek.workers.dev/?api_key=smdbgf23urr42hjh1jhj221e3';

  Future<Map<dynamic, dynamic>> fetchNotify() async {
    var response = await http.get(Uri.parse(_helperUrl));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['success'] == true) {
        var info = json.decode(data['text']);
        return {
          'success': true,
          'title': info['title'],
          'body': info['body'],
          'id': data['message_id']
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch notification: ${data['error'] ?? 'Unknown error'}'
        };
      }
    } else {
      return {
        'success': false,
        'message': 'Failed to fetch notification: Server error ${response.statusCode}'
      };
    }
  }

  Future<Map<String, dynamic>> uploadFile(String filePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$_apiUrl/upload'));
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      var data = json.decode(responseData.body);

      if (data['success'] == true) {
        return {
          'success': true,
          'id': data['id'],
          'link': data['durl'],
          'title': filePath.split('/').last,
          'size': File(filePath).lengthSync(),
          'view': data['vurl']
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to upload file: ${data['error'] ?? 'Unknown error'}'
        };
      }
    } else {
      return {
        'success': false,
        'message': 'Failed to upload file: Server error ${response.statusCode}'
      };
    }
  }
}

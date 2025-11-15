import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class APIService {
  static const String _apiUrl = 'https://picdb-api.arkynox.com/';
  static const String _baseUrlGroup = 'https://picdb.arkynox.com';

  Future<Map<dynamic, dynamic>> fetchNotify() async {
    var response = await http.get(Uri.parse('$_baseUrlGroup/api/notification'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['success'] == true) {
        return {
          'success': true,
          'notifications': data['notifications'] ?? []
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

  // Group-related APIs
  static Future<Map<String, dynamic>> createGroup({
    required String username,
    required String uid,
    required String password,
    String? groupName,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrlGroup/api/groups'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'uid': uid,
          'password': password,
          'groupName': groupName,
        }),
      );

      return jsonDecode(res.body);
    } catch (e) {
      print('Error creating group: $e');
      return {
        'success': false,
        'message': 'Error creating group',
      };
    }
  }

  static Future<Map<String, dynamic>> joinGroup({
    required String code,
    required String uid,
    required String password,
    required String username,
  }) async {
    try {
      final res = await http.post(  // Changed from POST to PUT to match TypeScript
        Uri.parse('$_baseUrlGroup/api/groups/join'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': code,
          'uid': uid,
          'password': password,
          'username': username,
        }),
      );

      return jsonDecode(res.body);
    } catch (e) {
      print('Error joining group: $e');
      return {
        'success': false,
        'message': 'Error joining group',
      };
    }
  }

  static Future<Map<String, dynamic>> getGroupDetails({
    required String groupId,
    required String code,
    required String uid,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrlGroup/api/groups?groupId=$groupId&code=$code&uid=$uid'),
      );
      return jsonDecode(res.body);
    } catch (e) {
      print('Error fetching group details: $e');
      return {
        'success': false,
        'message': 'Error fetching group details',
      };
    }
  }

  static Future<Map<String, dynamic>> getUserGroups(String userId) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrlGroup/api/groups/user?userId=$userId'),  // Updated to use userId param
      );
      return jsonDecode(res.body);
    } catch (e) {
      print('Error fetching user groups: $e');
      return {
        'success': false,
        'message': 'Error fetching user groups',
      };
    }
  }

  static Future<Map<String, dynamic>> updateGroupName({
    required String groupId,
    required String name,  // Changed from newName to match TypeScript
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrlGroup/api/groups/name'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'groupId': groupId,
          'name': name,
        }),
      );

      return jsonDecode(res.body);
    } catch (e) {
      print('Error updating group name: $e');
      return {
        'success': false,
        'message': 'Error updating group name',
      };
    }
  }

  static Future<Map<String, dynamic>> fetchUsername(String uid) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrlGroup/api/groups/name?uid=$uid'),
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('Error fetching username: $e');  // Fixed error message
      return {
        'success': false,
        'message': 'Error fetching username',  // Fixed error message
      };
    }
  }

  static Future<Map<String, dynamic>> fetchGroups(String uid) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrlGroup/api/groups/info?uid=$uid'),
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('Error fetching groups: $e');  // Fixed error message
      return {
        'success': false,
        'message': 'Error fetching groups',  // Fixed error message
      };
    }
  }

  static Future<Map<String, dynamic>> setUsernameAPI(String username) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrlGroup/api/auth/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': username}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out');
        },
      );

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Error setting username',
        };
      }

      try {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] == true,
          'id': data['id'],
          'message': data['message'],
        };
      } catch (e) {
        print('Failed to parse JSON response: $e');
        return {
          'success': false,
          'message': 'Failed to parse server response',
        };
      }
    } catch (e) {
      print('Error setting username: $e');
      return {
        'success': false,
        'message': 'Error setting username',
      };
    }
  }

  Future<Map<String, dynamic>> fetchGroupMessages({
    required String groupId,
    required String code,
    required String uid,
    String? username,
    String? lastMessageId,
    int limit = 20,
  }) async {
    try {
      // First get the group details including messages
      final queryParams = {
        'groupId': groupId,
        'code': code,
        'uid': uid,
      };
      final res = await http.get(
          Uri.parse('$_baseUrlGroup/api/groups?groupId=${groupId}&code=${code}&uid=${uid}'),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          // Check for custom group name in shared preferences
          final savedGroupsStr = await SharedPreferences.getInstance()
              .then((prefs) => prefs.getString('grouproom_saved_groups') ?? '[]');
          final savedGroups = jsonDecode(savedGroupsStr) as List;
          final savedGroup = savedGroups.firstWhere(
            (g) => g['id'] == groupId,
            orElse: () => null,
          );

          // Update response with custom name if available
          if (data['group'] != null && savedGroup != null && savedGroup['customName'] != null) {
            data['group']['name'] = savedGroup['customName'];
          }

          if (username != null) {
            data['group']['username'] = username;
          }

          return {
            'success': true,
            'group': data['group'],
            'messages': data['messages'] ?? [],
            'members': data['members'] ?? [],
          };
        }
      }
      return {
        'success': false,
        'message': 'Failed to fetch messages: Server error ${res.statusCode}',
      };
    } catch (e) {
      print('Error fetching messages: $e');
      return {
        'success': false,
        'message': 'Failed to fetch messages',
      };
    }
  }

  Future<Map<String, dynamic>> sendImageMessage({
    required String groupId,
    required String code,
    required String uid,
    required String username,
    required File file,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrlGroup/api/groups/messages');
      final req = http.MultipartRequest('POST', uri)
        ..fields['groupId'] = groupId
        ..fields['code'] = code
        ..fields['uid'] = uid
        ..fields['username'] = username
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed = await req.send();
      final response = await http.Response.fromStream(streamed);

      return jsonDecode(response.body);
    } catch (e) {
      print('Error sending image message: $e');
      return {
        'success': false,
        'message': 'Failed to send image',
      };
    }
  }
}

class GroupItem {
  final String id;
  final String name;
  final String code;
  final String? lastMessage;
  final int unread;

  GroupItem({
    required this.id,
    required this.name,
    required this.code,
    this.lastMessage,
    this.unread = 0,
  });

  factory GroupItem.fromJson(Map<String, dynamic> j) => GroupItem(
    id: j['id'].toString(),
    name: j['name'] ?? 'Group',
    code: j['code'] ?? '',
    lastMessage: j['lastMessage'],
    unread: (j['unread'] ?? 0) as int,
  );
}

class ImageMessage {
  final String id;
  final String username;
  final String url;
  final DateTime createdAt;
  final bool mine;

  ImageMessage({
    required this.id,
    required this.username,
    required this.url,
    required this.createdAt,
    this.mine = false,
  });

  factory ImageMessage.fromJson(Map<String, dynamic> j, String meUid) {
    return ImageMessage(
      id: j['id'].toString(),
      username: j['username'] ?? 'User',
      url: j['imageUrl'] ?? j['url'] ?? '',
      createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
      mine: (j['uid']?.toString() ?? '') == meUid,
    );
  }
}
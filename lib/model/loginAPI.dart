import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:kitty_burger_app/model/global.dart';

class LoginClass {
  static final _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> loginFunctionApi(
      Map<dynamic, dynamic> loginParameters) async {
    String saveURLDomain = await globaldomain.insert_Domain();
    try {
      var uri = Uri.parse('$saveURLDomain/kitty_burger/api/loginUser');
      var param = loginParameters;

      final response = await http.post(uri, body: jsonEncode(param), headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Credentials': 'true',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'GET,PUT,POST,DELETE'
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true) {
          var dataList = data['data'] as List?;
          if (dataList != null && dataList.isNotEmpty) {
            var userData = dataList[0] as Map<String, dynamic>;
            var userId = userData['id'];
            var username = userData['username'];
            var image = userData['image'];

            var address =
                userData['address']; // Assuming image is provided in response

            if (userId != null && username != null) {
              await _storage.write(key: 'id', value: userId.toString());
              await _storage.write(key: 'username', value: username.toString());
              await _storage.write(key: 'address', value: address.toString());
              if (image != null) {
                await _storage.write(key: 'image', value: image.toString());
              }
              ;
              return {"success": true, "message": 'Login successful'};
            } else {
              return {
                'success': false,
                'message': 'User ID or username is missing in the response data'
              };
            }
          } else {
            return {
              'success': false,
              'message': 'User data is missing or malformed'
            };
          }
        } else {
          return {
            'success': false,
            'message': 'User not found, please check username or password'
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Validation errors',
          'data': {
            'username': ['The username field is required.'],
            'password': ['The password field is required.']
          }
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString(), 'data': ''};
    }
  }

  static Future<String?> getSessionID() async {
    return await _storage.read(key: 'id');
  }

  static Future<String?> getSessionUsername() async {
    return await _storage.read(key: 'username');
  }

  static Future<String?> getSessionImage() async {
    return await _storage.read(key: 'image');
  }

  static Future<String?> getSessionAddress() async {
    return await _storage.read(key: 'address');
  }
}

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kitty_burger_app/model/global.dart';

// ignore: camel_case_types
class registerSaveINfoClass {
  static Future<Map> RegisterData(Map<dynamic, dynamic> SaveDetailsUser) async {
    Map<String, dynamic> returnArray;

    String _saveURLdomain = await globaldomain.insert_Domain();
    try {
      // var uri = Uri.parse(
      //     'http://ww2.voxdeisystems.com/$_saveURLdomainCALI/api/upload_rwt');

      var uri = Uri.parse('$_saveURLdomain/kitty_burger/api/registerUser');
      var param = SaveDetailsUser;

      final response = await http.post(uri, body: jsonEncode(param), headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Credentials': 'true',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'GET,PUT,POST,DELETE'
      });

      Map data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          returnArray = {
            "success": true,
            "message":
                "User registration success, please proceed for verification and provide the verification code sent to your email",
            'data': data['data']
          };
        } else {
          returnArray = {
            'success': false,
            'message': 'register Info user is failed',
            'data': {
              'last_name': ['The last name field is required.'],
              'first_name': ['The first name field is required.'],
              'middle_name': ['The middle name field is required.'],
              'address': ['The address field is required.'],
              'birth_date': ['The birth date field is required.'],
              'email': ['The email field is required.'],
              'mobile': ['The mobile field is required.'],
              'image': ['The image field is required.'],
              'username': ['The username field is required.'],
              'password': ['The password field is required.']
            }
          };
        }
      } else {
        returnArray = {
          'success': false,
          'message': 'register Info user is failed',
          'data': {
            'last_name': ['The last name field is required.'],
            'first_name': ['The first name field is required.'],
            'middle_name': ['The middle name field is required.'],
            'address': ['The address field is required.'],
            'birth_date': ['The birth date field is required.'],
            'email': ['The email field is required.'],
            'mobile': ['The mobile field is required.'],
            'image': ['The image field is required.'],
            'username': ['The username field is required.'],
            'password': ['The password field is required.']
          }
        };
      }
      return returnArray;
    } catch (e) {
      return {'success': false, 'message': e.toString(), 'data': ''};
    }
  }
}

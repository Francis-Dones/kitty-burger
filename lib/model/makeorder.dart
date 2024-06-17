// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kitty_burger_app/model/global.dart';

// ignore: camel_case_types
class MakeorderClass {
  static Future<Map> makeorderData(Map<dynamic, dynamic> makeorders) async {
    Map<String, dynamic> returnArray;
    String _saveURLdomain = await globaldomain.insert_Domain();
    try {
      var uri = Uri.parse('$_saveURLdomain/kitty_burger/api/makeOrder');
      var param = makeorders;

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
          returnArray = {"success": true, "message": 'New order saved.'};
        } else {
          returnArray = {
            'success': false,
            'message': 'Creating default object from empty value',
            'data': {
              "user_id": ["The user id field is required."],
              'delivery_address': ['The delivery address field is required.']
            }
          };
        }
      } else {
        returnArray = {
          'success': false,
          'message': 'Creating default object from empty value'
        };
      }
      return returnArray;
    } catch (e) {
      return {'success': false, 'message': e.toString(), 'data': ''};
    }
  }
}

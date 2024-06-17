// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kitty_burger_app/model/global.dart';

// ignore: camel_case_types
class payorderClass {
  static Future<Map> payorderData(Map<dynamic, dynamic> SaveDetailsUser) async {
    Map<String, dynamic> returnArray;

    String _saveURLdomain = await globaldomain.insert_Domain();
    try {
      // var uri = Uri.parse(
      //     'http://ww2.voxdeisystems.com/$_saveURLdomainCALI/api/upload_rwt');

      var uri = Uri.parse('$_saveURLdomain/kitty_burger/api/payOrder');
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
            "message": "Payment Proof Successful",
            'data': data['data']
          };
        } else {
          returnArray = {
            'success': false,
            "message": "Validation errors",
            'data': {
              'order_id': ['The selected order id is invalid.'],
              'payment_proof': ["The payment proof field is required."]
            }
          };
        }
      } else {
        returnArray = {
          'success': false,
          'message': 'add to cart failed',
        };
      }
      return returnArray;
    } catch (e) {
      return {'success': false, 'message': e.toString(), 'data': ''};
    }
  }
}

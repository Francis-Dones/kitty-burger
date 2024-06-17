import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import FlutterSecureStorage
import 'package:http/http.dart' as http;
import 'package:kitty_burger_app/model/global.dart';

class Order {
  final int orderId;
  final String userId;
  final String deliveryAddress;
  final int paid;
  final String dateTime;
  final String status;
  final String processedBy;

  Order({
    required this.orderId,
    required this.userId,
    required this.deliveryAddress,
    required this.paid,
    required this.dateTime,
    required this.status,
    required this.processedBy,
  });
}

class GetOrdersApi {
  static final _storage =
      const FlutterSecureStorage(); // Instantiate FlutterSecureStorage

  static Future<String?> getSessionorder_id() async {
    return await _storage.read(key: 'order_id');
  }

  static Future<Map<String, dynamic>> getOrdersData(
      Map<String, dynamic> saveDetailsUser) async {
    try {
      String _saveURLdomain = await globaldomain.insert_Domain();
      final uri = Uri.parse('$_saveURLdomain/kitty_burger/api/getOrders');
      final headers = {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Credentials': 'true',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'GET, PUT, POST, DELETE'
      };

      final response = await http.post(uri,
          body: jsonEncode(saveDetailsUser), headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic data = jsonDecode(response.body);

        if (data['data'] is List<dynamic>) {
          List<Order> orderList = [];
          for (var orderData in data['data']) {
            if (orderData is Map<String, dynamic> &&
                orderData.containsKey('order_id') &&
                orderData.containsKey('user_id') &&
                orderData.containsKey('delivery_address') &&
                orderData.containsKey('paid') &&
                orderData.containsKey('date_time') &&
                orderData.containsKey('status') &&
                orderData.containsKey('processed_by')) {
              orderList.add(Order(
                orderId: int.parse(orderData['order_id'].toString()),
                userId: orderData['user_id'].toString(),
                deliveryAddress: orderData['delivery_address'].toString(),
                paid: int.parse(orderData['paid'].toString()),
                dateTime: orderData['date_time'].toString(),
                status: orderData['status'].toString(),
                processedBy: orderData['processed_by'].toString(),
              ));
            } else {
              return {
                'success': false,
                'message': 'Invalid data format for order: $orderData',
                'data': null,
              };
            }
          }
          return {
            'success': true,
            'message': 'Orders Retrieved Successfully',
            'data': orderList,
          };
        } else {
          return {
            'success': false,
            'message': 'Invalid data type received',
            'data': null,
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch orders: ${response.reasonPhrase}',
          'data': null,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
        'data': null,
      };
    }
  }
}

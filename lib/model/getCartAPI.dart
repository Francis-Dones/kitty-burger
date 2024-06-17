import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kitty_burger_app/model/global.dart';

class Item {
  final int product_id;
  final int quantity;
  final String request;
  final String name;
  final double price;
  final String image;
  final double total;

  Item({
    required this.product_id,
    required this.quantity,
    required this.request,
    required this.name,
    required this.price,
    required this.image,
    required this.total,
  });
}

class GetCartApi {
  static Future<Map<String, dynamic>> getCartData(
      Map<String, dynamic> saveDetailsUser) async {
    try {
      String _saveURLdomain = await globaldomain.insert_Domain();
      final uri = Uri.parse('$_saveURLdomain/kitty_burger/api/getCart');
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
          List<Item> itemList = [];
          for (var product in data['data']) {
            if (product is Map<String, dynamic> &&
                product.containsKey('product_id') &&
                product.containsKey('quantity') &&
                product.containsKey('request') &&
                product.containsKey('name') &&
                product.containsKey('price') &&
                product.containsKey('image') &&
                product.containsKey('total')) {
              itemList.add(Item(
                product_id: int.parse(product['product_id'].toString()),
                name: product['name'].toString(),
                quantity: int.parse(product['quantity'].toString()),
                price: double.parse(product['price'].toString()),
                image: product['image'].toString(),
                total: double.parse(product['total'].toString()),
                request: product['request'].toString(),
              ));
            } else {
              return {
                'success': false,
                'message': 'Invalid data format for product: $product',
                'data': null,
              };
            }
          }
          return {
            'success': true,
            'message': 'Product Retrieved Successfully',
            'data': itemList,
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
          'message': 'Failed to fetch products: ${response.reasonPhrase}',
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

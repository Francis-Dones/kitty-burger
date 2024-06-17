import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kitty_burger_app/model/global.dart';

class Item {
  final String name;

  final double price;
  final int quantity;
  final String image;
  final String total; // New field
  final String request; // New field

  Item({
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    required this.total,
    required this.request,
  });
}

class orderDetailsClass {
  static Future<List<Item>> orderDetailsData(
      Map<String, dynamic> saveDetailsUser) async {
    try {
      String _saveURLdomain = await globaldomain.insert_Domain();
      var uri = Uri.parse('$_saveURLdomain/kitty_burger/api/getAllproducts');
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Credentials': 'true',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'GET,PUT,POST,DELETE'
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic data = jsonDecode(response.body);
        if (data is List<dynamic>) {
          List<Item> itemList = [];
          for (var product in data) {
            if (product is Map<String, dynamic> &&
                product.containsKey('name') &&
                product.containsKey('request') &&
                product.containsKey('price') &&
                product.containsKey('quantity') &&
                product.containsKey('image') &&
                product.containsKey('total')) {
              // Check for 'total' field
              itemList.add(Item(
                name: product['name'],

                price: double.tryParse(product['price']) ?? 0.0,
                quantity: int.tryParse(product['quantity']) ?? 0,
                image: product['image'],
                total: product['total'], // New field
                request: product['request'], // New field
              ));
            } else {
              throw Exception('Invalid data format for product: $product');
            }
          }
          return itemList;
        } else {
          throw Exception('Invalid data format');
        }
      } else if (response.statusCode == 404) {
        // Handle 404 error
        throw Exception('Failed to fetch data: Not Found (404)');
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }
}

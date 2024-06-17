import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kitty_burger_app/model/global.dart';

class Item {
  final int product_id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String image;
  final String category;
  final int is_active;

  Item({
    required this.product_id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.image,
    required this.category,
    required this.is_active,
  });
}

class ProductClass {
  static Future<List<Item>> productData() async {
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
                product.containsKey('product_id') &&
                product.containsKey('name') &&
                product.containsKey('description') &&
                product.containsKey('price') &&
                product.containsKey('quantity') &&
                product.containsKey('image') &&
                product.containsKey('category') &&
                product.containsKey('is_active')) {
              itemList.add(Item(
                product_id: product['product_id'],
                name: product['name'],
                description: product['description'],
                price: product['price'] is int
                    ? (product['price'] as int).toDouble()
                    : double.tryParse(product['price'].toString()) ?? 0.0,
                quantity: product['quantity'] is int
                    ? (product['quantity'] as int)
                    : int.tryParse(product['quantity'].toString()) ?? 0,
                image: product['image'],
                category: product['category'],
                is_active: product['is_active'],
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

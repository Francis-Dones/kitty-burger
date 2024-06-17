import 'dart:convert'; // Import for JSON encoding and decoding
import 'package:http/http.dart' as http;
import 'package:kitty_burger_app/model/global.dart'; // Assuming this is your own package

class Item {
  final String name;
  final double price;
  final int quantity;
  final String image;
  final String total;
  final String request;

  Item({
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    required this.total,
    required this.request,
  });
}

class ViewOrderClass {
  static Future<List<Item>> VieworderData(
      Map<String, dynamic> saveDetailsUser) async {
    try {
      String _saveURLdomain = await globaldomain.insert_Domain();
      var uri = Uri.parse('$_saveURLdomain/kitty_burger/api/getOrder');
      final response = await http.post(
        uri,
        body: jsonEncode(saveDetailsUser),
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Credentials': 'true',
          'Access-Control-Allow-Headers': 'Content-Type',
          'Access-Control-Allow-Methods': 'GET,PUT,POST,DELETE'
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          List<Item> itemList = [];
          var orderItems = jsonData['data']['order_items'];

          for (var itemData in orderItems) {
            itemList.add(Item(
              name: itemData['name'],
              price: double.parse(itemData['price']),
              quantity: int.parse(itemData['quantity']),
              image: itemData['image'],
              total: itemData['total'],
              request: itemData['request'] ?? '',
            ));
          }

          return itemList;
        } else {
          throw Exception('Failed to retrieve order: ${jsonData['message']}');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Failed to fetch data: Not Found (404)');
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }
}

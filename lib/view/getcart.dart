import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kitty_burger_app/model/getCartAPI.dart';
import 'package:kitty_burger_app/model/global.dart';
import 'package:kitty_burger_app/model/makeorder.dart';
import 'package:kitty_burger_app/view/product.dart';

class Item {
  final int product_id;
  final String name;
  final String image;
  final double price;
  int quantity; // Changed to non-final to allow updating
  final String request;
  double total;

  Item({
    required this.product_id,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.request,
    required this.total,
  });
}

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late ValueNotifier<double> _subtotalNotifier;
  List<Item> items = [];

  @override
  void initState() {
    _showDialogCheckInternet();
    super.initState();
  }

  Future<void> _loadData() async {
    _subtotalNotifier = ValueNotifier<double>(0.0);
    _getCartItem();
    globalDomain();
    getAddressFromStorage();
  }

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      return true;
    }
  }

  void _showDialogCheckInternet() async {
    bool isConnected = await checkInternetConnectivity();
    if (!isConnected) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Connection Failed"),
            content: Text("Please Connect Internet"),
            actions: <Widget>[
              TextButton(
                child: Text("Close"),
                onPressed: () {
                  SystemNavigator.pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      _loadData();
    }
  }

  void getAddressFromStorage() async {
    const _storage = FlutterSecureStorage(); // Initialize secure storage

    // Retrieve session ID asynchronously
    String? storedAddress = await _storage.read(key: 'address');

    // Update the state with the retrieved address
    setState(() {
      address = storedAddress;
      addressController.text = address.toString();
    });
  }

  var address;
  var addressController = TextEditingController();

  String _saveURLdomain = "";

  bool _isLoading = true; // Added to track loading state
  bool _hasError = false; // Added to track error state

  void globalDomain() async {
    String saveURLdomain = await globaldomain.insert_Domain();
    setState(() {
      _saveURLdomain = saveURLdomain;
    });
  }

  void _getCartItem() async {
    const _storage = FlutterSecureStorage();

    String? userID = await _storage.read(key: 'id');

    try {
      if (userID != null) {
        Map<String, dynamic> saveDetailsUser = {
          'user_id': userID,
        };

        Map<String, dynamic> response =
            await GetCartApi.getCartData(saveDetailsUser);

        if (response['success'] == true) {
          List<Item> itemList = (response['data'] as List).map((product) {
            return Item(
              product_id: product.product_id,
              name: product.name,
              image: product.image,
              price: product.price,
              quantity: product.quantity,
              request: product.request,
              total: product.total,
            );
          }).toList();

          setState(() {
            items = itemList;
            updateSubtotal();
            _isLoading = false; // Set loading state to false
          });
        } else {
          setState(() {
            _isLoading = false; // Set loading state to false
            _hasError = true; // Set error state to true
          });
        }
      } else {
        setState(() {
          _isLoading = false; // Set loading state to false
          _hasError = true; // Set error state to true
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Set loading state to false
        _hasError = true; // Set error state to true
      });
    }
  }

  void updateSubtotal() {
    double newSubtotal = 0.0;
    for (var item in items) {
      newSubtotal += item.price * item.quantity;
    }
    _subtotalNotifier.value = newSubtotal;
  }

  void _checkout() {
    _showSnackBar('Proceeding to checkout...', true);
    _showConfirmAddressDialog();
  }

  void MakeOrder() async {
    const _storage = FlutterSecureStorage(); // Initialize secure storage
    try {
      // Retrieve session ID asynchronously
      String? userID = await _storage.read(key: 'id');

      // Check if userID is null or empty
      if (userID == null || userID.isEmpty) {
        // Handle the case where userID is null or empty
        _showSnackBar("User ID not found", false);
        return;
      }

      Map<String, dynamic> makeorderData = {
        'user_id': userID,
        'delivery_address':
            addressController.text.toString(), // Convert to string
      };

      // Assuming AddtocartData is an asynchronous function
      Map<dynamic, dynamic> result =
          await MakeorderClass.makeorderData(makeorderData);

      if (result['success'] == true) {
        _showSnackBar(result['message'], true);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const ProductView(
                  title: 'home',
                )));
      } else {
        _showSnackBar(result['message'], false);
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e", false);
    }
  }

  void _showConfirmAddressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const DefaultTextStyle(
            style: TextStyle(color: Colors.black),
            child: Column(
              children: [
                Text('Confirm Address'),
                Divider(color: Colors.white),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Please enter your address:',
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Address',
                  filled: true, // Needed for adding a fill color
                  fillColor: const Color.fromARGB(255, 244, 239, 239),
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Column(
              children: [
                const Divider(color: Colors.white),
                Row(
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Dismiss the dialog
                      },
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.red)),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        MakeOrder();
                        Navigator.of(context).pop(); // Dismiss the dialog
                      },
                      child: const Text('Confirm',
                          style: TextStyle(color: Colors.green)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cart',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 234, 34, 147),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? const Center(
                  child: Text('Empty List Item'),
                )
              : items.isEmpty
                  ? const Center(
                      child: Text('Your cart is empty'),
                    )
                  : Column(
                      children: <Widget>[
                        Expanded(
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              String requestText = (item.request == "null " ||
                                      item.request == "null")
                                  ? ''
                                  : 'Request: ${item.request}';
                              return ListTile(
                                title: Text(item.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Price: ₱${item.price.toStringAsFixed(2)}'),
                                    if (requestText.isNotEmpty)
                                      Text(requestText),
                                    Text('Quantity: ${item.quantity}'),
                                  ],
                                ),
                                leading: Image.network(
                                    '$_saveURLdomain/kitty_burger/public/images/products/${item.image}'),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                              ValueListenableBuilder<double>(
                                valueListenable: _subtotalNotifier,
                                builder: (context, subtotal, child) {
                                  return Text(
                                    'Total: ₱${subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                              ElevatedButton(
                                onPressed: _checkout,
                                child: const Text('Confirm'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
      backgroundColor: const Color.fromARGB(255, 247, 178, 217),
    );
  }

  void _showSnackBar(String message, bool success) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

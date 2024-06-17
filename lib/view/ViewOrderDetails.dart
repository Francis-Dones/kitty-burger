import 'dart:convert'; // Import dart:convert for Base64 encoding
import 'dart:io'; // Import dart:io for File class

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import the image picker package
import 'package:kitty_burger_app/model/global.dart';
import 'package:kitty_burger_app/model/payOrderAPI.dart';
import 'package:kitty_burger_app/model/viewOrder.dart'
    as viewOrder; // Use alias for viewOrder
import 'package:kitty_burger_app/view/order.dart';

class OrderDetailsView extends StatefulWidget {
  final int orderId; // Define orderId as a parameter

  // Constructor to initialize orderId
  const OrderDetailsView(this.orderId);

  @override
  _OrderDetailsViewState createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  List<viewOrder.Item> _orderItems = []; // List to hold order items
  File? _image; // File variable to hold the selected image
  String _saveURLdomain = "";
  bool _isLoading = false; // Variable to manage loading state
  String _selectedReason = 'Wrong Address'; // Default selected reason

  @override
  void initState() {
    super.initState();
    _fetchOrderData(); // Call function to fetch order data when widget initializes
    globalDomain();
  }

  void globalDomain() async {
    String saveURLdomain = await globaldomain.insert_Domain();
    setState(() {
      _saveURLdomain = saveURLdomain;
    });
  }

  Future<void> _fetchOrderData() async {
    try {
      // Simulating user details to be passed to the function
      Map<String, dynamic> userDetails = {
        'order_id': widget.orderId, // Access orderId through widget property
      };

      // Call VieworderData function to fetch order data
      List<viewOrder.Item> orderItems =
          await viewOrder.ViewOrderClass.VieworderData(userDetails);

      // Update the state with the fetched order items
      setState(() {
        _orderItems = orderItems;
      });
    } catch (e) {
      // Handle any errors that occur during data fetching
      print('Error fetching order data: $e');
    }
  }

  void _showSnackBar(String _text, bool _isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: _isSuccess ? Colors.green : Colors.red,
      content: Text(_text),
    ));
  }

  void payOrder() async {
    if (_image == null) {
      _showSnackBar("Please select an image first", false);
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Convert image to Base64
      List<int> imageBytes = await _image!.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      Map<String, dynamic> orderpayment = {
        'order_id': widget.orderId,
        'payment_proof': base64Image, // Send the Base64 string
      };

      // Assuming AddtocartData is an asynchronous function
      Map<dynamic, dynamic> result =
          await payorderClass.payorderData(orderpayment);

      if (result['success'] == true) {
        _showSnackBar(result['message'], true);
        orderPage();
      } else {
        _showSnackBar(result['message'], false);
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e", false);
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  void orderPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderCart(),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _payOrder() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Proof Of Payment'),
              content: _image == null
                  ? const Text('No image selected.')
                  : Image.file(_image!),
              actions: <Widget>[
                TextButton(
                  child: const Text('Select Proof Image'),
                  onPressed: () async {
                    await _pickImage();
                    setState(() {}); // Update the dialog content
                  },
                ),
                TextButton(
                  child: const Text('Pay Order'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    payOrder(); // Call payOrder function
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCancelOrderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Cancel Order'),
              content: DropdownButton<String>(
                value: _selectedReason,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedReason = newValue!;
                  });
                },
                items: <String>['Wrong Address', 'Wrong Order', 'change order']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Confirm'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // _cancelOrder(); // Call cancel order function
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // void _cancelOrder() async {
  //   setState(() {
  //     _isLoading = true; // Show loading indicator
  //   });

  //   try {
  //     Map<String, dynamic> cancelData = {
  //       'order_id': widget.orderId,
  //       'cancel_reason': _selectedReason, // Send the selected reason
  //     };

  //     // Assuming CancelOrderData is an asynchronous function
  //     Map<dynamic, dynamic> result = await cancelOrderClass.cancelOrderData(cancelData);

  //     if (result['success'] == true) {
  //       _showSnackBar(result['message'], true);
  //       orderPage();
  //     } else {
  //       _showSnackBar(result['message'], false);
  //     }
  //   } catch (e) {
  //     _showSnackBar("An error occurred: $e", false);
  //   } finally {
  //     setState(() {
  //       _isLoading = false; // Hide loading indicator
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 234, 34, 147),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _orderItems.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(),
                      ) // Show loading indicator while data is being fetched
                    : ListView.builder(
                        itemCount: _orderItems.length,
                        itemBuilder: (context, index) {
                          viewOrder.Item item = _orderItems[index];
                          return ListTile(
                            title: Text(item.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Price: ₱${item.price.toStringAsFixed(2)}'),
                                Text('Request: ${item.request}'),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _payOrder,
                      child: const Text('Pay Order'),
                    ),
                    ElevatedButton(
                      onPressed: _showCancelOrderDialog,
                      child: const Text('Cancel Order'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 247, 178, 217),
    );
  }
}

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kitty_burger_app/model/getOrdersAPI.dart';
import 'package:kitty_burger_app/model/global.dart';
import 'package:kitty_burger_app/view/ViewOrderDetails.dart';

class Item {
  final int orderId;
  final String userId;
  final String deliveryAddress;
  final int paid;
  final String dateTime;
  final String status;
  final String processedBy;

  Item({
    required this.orderId,
    required this.userId,
    required this.deliveryAddress,
    required this.paid,
    required this.dateTime,
    required this.status,
    required this.processedBy,
  });
}

class OrderCart extends StatefulWidget {
  @override
  _OrderCartState createState() => _OrderCartState();
}

class _OrderCartState extends State<OrderCart> {
  late ValueNotifier<double> _subtotalNotifier;
  List<Item> items = [];

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    _subtotalNotifier = ValueNotifier<double>(0.0);
    _getOrderItems();
    globalDomain();
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

  String _saveURLdomain = "";
  bool _isLoading = true;
  bool _hasError = false;

  void globalDomain() async {
    String saveURLdomain = await globaldomain.insert_Domain();
    setState(() {
      _saveURLdomain = saveURLdomain;
    });
  }

  void _getOrderItems() async {
    final _storage = const FlutterSecureStorage();

    String? userID = await _storage.read(key: 'id');

    try {
      if (userID != null) {
        Map<String, dynamic> saveDetailsUser = {
          'user_id': userID,
        };

        // Fetch orders using the API
        Map<String, dynamic> response =
            await GetOrdersApi.getOrdersData(saveDetailsUser);

        if (response['success'] == true) {
          List<Item> itemList = (response['data'] as List).map((product) {
            return Item(
              orderId: product.orderId,
              userId: product.userId,
              deliveryAddress: product.deliveryAddress,
              paid: product.paid,
              dateTime: product.dateTime,
              status: product.status,
              processedBy: product.processedBy,
            );
          }).toList();

          setState(() {
            items = itemList;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Orders',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 234, 34, 147),
      ),
      body: SingleChildScrollView(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasError
                ? const Center(child: Text('Error fetching orders'))
                : items.isEmpty
                    ? const Center(child: Text('No orders found'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          // ignore: prefer_const_literals_to_create_immutables
                          columns: [
                            const DataColumn(label: Text('Order ID')),

                            const DataColumn(label: Text('Delivery Address')),
                            const DataColumn(label: Text('Paid')),
                            const DataColumn(label: Text('Date Time')),
                            const DataColumn(label: Text('Status')),

                            const DataColumn(
                                label: const Text(
                                    'Actions')), // Add Actions column
                          ],
                          rows: items.map((item) {
                            return DataRow(cells: [
                              DataCell(Text(item.orderId.toString())),
                              DataCell(Text(item.deliveryAddress)),
                              DataCell(Text(item.paid == 1 ? "yes" : "no")),
                              DataCell(Text(item.dateTime)),
                              DataCell(Text(item.status)),
                              DataCell(IconButton(
                                icon: const Icon(Icons.visibility),
                                onPressed: () {
                                  // Handle button press, e.g., navigate to details screen
                                  _viewItemDetails(item);
                                },
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
      ),
      backgroundColor: const Color.fromARGB(255, 247, 178, 217),
    );
  }

  void _viewItemDetails(Item item) {
    // Handle navigation or any other action with the selected item
    // For example, you can navigate to a details screen and pass the item
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsView(item.orderId),
      ),
    );
  }
}

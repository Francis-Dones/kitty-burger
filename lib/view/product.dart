import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kitty_burger_app/model/addtocartAPI.dart';
import 'package:kitty_burger_app/model/getCartAPI.dart';
import 'package:kitty_burger_app/model/global.dart';
import 'package:kitty_burger_app/model/productAPI.dart';
import 'package:kitty_burger_app/view/getcart.dart';
import 'package:kitty_burger_app/view/home.dart';
import 'package:kitty_burger_app/view/main_menu.dart';
import 'package:kitty_burger_app/view/order.dart';

class ProductView extends StatefulWidget {
  const ProductView({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<ProductView> createState() => _ProductViewState();
}

class Item {
  final int product_id;
  final String name;
  final double price;
  int quantity;
  final String image;
  DateTime dateTime;
  bool isChecked;
  late int availableOrder;
  final String description;

  Item({
    required this.product_id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    required this.dateTime,
    this.isChecked = false,
    required this.availableOrder,
    required String description,
  }) : description = description;
}

class _ProductViewState extends State<ProductView> {
  List<Item> cartItems = [];
  double subtotal = 0.0;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  List<Item> productList = [];

  int _cartItemCount = 0;

  void product() async {
    try {
      List<dynamic> products = await ProductClass.productData();
      List<Item> itemList = products.map((product) {
        return Item(
          product_id: product.product_id,
          name: product.name,
          price: product.price.toDouble(),
          quantity: 1,
          image: product.image,
          dateTime: DateTime.now(),
          description: product.description,
          availableOrder: product.quantity,
        );
      }).toList();

      setState(() {
        productList = itemList;
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void addItem(Item item) {
    setState(() {
      item.dateTime = DateTime.now();
      cartItems.add(item);
      subtotal += item.price + item.quantity;
    });
  }

  void addToCart(String productId, int quantity, String remarks) async {
    final _storage = const FlutterSecureStorage(); // Initialize secure storage
    try {
      // Retrieve session ID asynchronously
      String? userID = await _storage.read(key: 'id');

      // Check if userID is null or empty
      if (userID == null || userID.isEmpty) {
        // Handle the case where userID is null or empty
        _showSnackBar("User ID not found", false);
        return;
      }

      Map<String, dynamic> cartData = {
        'user_id': userID,
        'product_id': productId.toString(), // Convert to string
        'quantity': quantity.toString(), // Convert to string
        'remarks': remarks
      };

      // Assuming AddtocartData is an asynchronous function
      Map<dynamic, dynamic> result =
          await AddtocartClass.AddtocartData(cartData);

      if (result['success'] == true) {
        _showSnackBar(result['message'], true);
        await _getCartItemCount(); // Refresh the cart item count after adding to cart
      } else {
        _showSnackBar(result['message'], false);
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e", false);
    }
  }

  Future<void> _getCartItemCount() async {
    final _storage = const FlutterSecureStorage();
    try {
      String? userID = await _storage.read(key: 'id');

      if (userID == null || userID.isEmpty) {
        _showSnackBar("User ID not found", false);
        return;
      }

      Map<String, dynamic> cartdata = {
        'user_id': userID,
      };

      Map<dynamic, dynamic> result = await GetCartApi.getCartData(cartdata);

      if (result['success'] == true) {
        setState(() {
          _cartItemCount = result['data']
              .length; // Assuming result['data'] is a list of cart items
        });
      } else {}
    } catch (e) {
      _showSnackBar("An error occurred: $e", false);
    }
  }

  void incrementItemQuantity(int index) {
    setState(() {
      cartItems[index].quantity += 1;
      subtotal += cartItems[index].price;
    });
  }

  void decrementItemQuantity(int index) {
    if (cartItems[index].quantity > 1) {
      setState(() {
        cartItems[index].quantity -= 1;
        subtotal -= cartItems[index].price;
      });
    } else {
      removeItem(index);
    }
  }

  void removeItem(int index) {
    setState(() {
      subtotal -= cartItems[index].price + cartItems[index].quantity;
      cartItems.removeAt(index);
    });
  }

  void checkOut() {
    if (cartItems.isEmpty) {
      _showSnackBar('Cart is empty! Add items before checking out.', false);
    } else {
      print('Checked out with total: ₱${subtotal.toStringAsFixed(2)}');
      _showSnackBar('Checkout successful!', true);
      clearCart();
    }
  }

  void clearCart() {
    setState(() {
      cartItems.clear();
      subtotal = 0.0;
    });
  }

  void _showSnackBar(String _text, bool _isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: _isSuccess ? Colors.green : Colors.red,
      content: Text(_text),
    ));
  }

  void navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(),
      ),
    );
  }

  // void _showDialog(BuildContext context, Item itemToAdd) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Are you sure you want to add this item?"),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               addItem(itemToAdd);
  //             },
  //             child: const Text("Yes"),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text("Cancel"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showDialog(BuildContext context, Item itemToAdd) {
    String remarks = ''; // Variable to store remarks

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text("Welcome to Kitty Burger!"),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Image.network(
                  "$_saveURLdomain/kitty_burger/public/images/products/${itemToAdd.image}",
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),

              Center(
                child: Column(
                  children: [
                    Text(
                      itemToAdd.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                        height: 8), // Adding some space between text and line
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color:
                                Colors.black, // You can change the color here
                            width: 6.0, // You can change the line width here
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Text('Stock ${itemToAdd.availableOrder}'),
              // Display product price
              Text('Price: ₱${itemToAdd.price.toStringAsFixed(2)}'),
              // Display product quantity
              Text('Quantity: ${itemToAdd.quantity}'),
              Text('Description: ${itemToAdd.description}'),
              // Remarks text field
              TextField(
                decoration: const InputDecoration(
                  hintText: 'notes:',
                ),
                onChanged: (value) {
                  remarks = value; // Update remarks as the user types
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                addToCart(itemToAdd.product_id.toString(), itemToAdd.quantity,
                    remarks); // Call addToCart with parameters
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    await Future.delayed(Duration(seconds: 3));
    product();
    globalDomain();
    _getCartItemCount();
    sessionloginuser();
    setState(() {
      _isLoading = false;
    });
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
  void globalDomain() async {
    String saveURLdomain = await globaldomain.insert_Domain();
    setState(() {
      _saveURLdomain = saveURLdomain;
    });
  }

  var _apiReturn;
  bool _isLoading = true;

  Future<void> signOut() async {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return const Homepage(
        title: 'home',
      );
    }));
  }

  List<String> images = [
    'lib/database/kittyBurger_logo.jpg',
  ];

  String userProfileImage = "";
  String username = "";

  // Asynchronous function to fetch domain

  void sessionloginuser() async {
    final _storage = const FlutterSecureStorage();
    String? imageuser = await _storage.read(key: 'image');
    String? username = await _storage.read(key: 'username');

    setState(() {
      userProfileImage = imageuser ?? "";
      this.username = username ?? "";
    });
  }

  Future<void> AccountSettings() async {}

  Future<void> AboutUS() async {}

  var myMenuItems = <String>[
    'Account Settings',
    'Logout',
  ];

  void onSelect(String item) {
    switch (item) {
      case 'Account Settings':
        print('Account Settings clicked');
        AccountSettings();
        break;
      case 'Logout':
        print('Logout clicked');
        signOut();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    List<Item> filteredProductList = productList
        .where((item) =>
            item.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 178, 217),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 234, 34, 147),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                  "$_saveURLdomain/kitty_burger/public/images/users/$userProfileImage"),
            ),
            const SizedBox(width: 20),
            Text(
              username.isNotEmpty ? username : 'Guest',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Container(
            color: const Color.fromARGB(110, 210, 190, 207),
            child: PopupMenuButton<String>(
              onSelected: onSelect,
              itemBuilder: (BuildContext context) {
                return myMenuItems.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products',
                      filled: true, // Needed for adding a fill color
                      fillColor: const Color.fromARGB(255, 244, 239, 239),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (query) {
                      setState(() {
                        searchQuery = query;
                      });
                    },
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Expanded(
                    child: ListView.builder(
                      itemCount: filteredProductList.length,
                      itemBuilder: (context, index) {
                        final product = filteredProductList[index];
                        return Card(
                          color: Colors.white,
                          child: ListTile(
                            leading: Image.network(
                              "$_saveURLdomain/kitty_burger/public/images/products/${product.image}",
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(product.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Price: ₱${product.price.toStringAsFixed(2)}'),
                                Text(product.availableOrder == 0
                                    ? 'Not available'
                                    : 'Stock: ${product.availableOrder}'),
                                Text(
                                  product.product_id.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    setState(() {
                                      if (product.quantity > 0) {
                                        product.quantity--;
                                      }
                                    });
                                  },
                                ),
                                Text(product.quantity.toString()),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      product.quantity++;
                                    });
                                  },
                                ),
                                if (product.availableOrder == 0 ||
                                    product.quantity == 0)
                                  IconButton(
                                    icon: const Icon(Icons.add_shopping_cart),
                                    onPressed: () {
                                      _showSnackBar(
                                          'Please select a quantity', false);
                                    },
                                  )
                                else
                                  IconButton(
                                    icon: const Icon(Icons.add_shopping_cart),
                                    onPressed: () {
                                      _showDialog(context, product);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 234, 34, 147),
        child: Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceEvenly, // Ensure even spacing between buttons
          children: [
            // Home Button
            Flexible(
              fit: FlexFit.tight,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return mainmenu(
                          signOut,
                          title: 'home',
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  height: screenSize.height * 0.08, // Set a fixed height
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(10), // Add border radius
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.015,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home,
                        color: Colors.black,
                        size: screenSize.width *
                            0.06, // Adjust icon size as needed
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 3),
            Flexible(
              fit: FlexFit.tight,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ProductView(
                            title: 'home',
                          )));
                },
                child: Container(
                  height: screenSize.height * 0.08, // Set a fixed height
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(10), // Add border radius
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.015,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.food_bank,
                        color: Colors.black,
                        size: screenSize.width *
                            0.06, // Adjust icon size as needed
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Product',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 3),
            Flexible(
              fit: FlexFit.tight,
              child: InkWell(
                onTap: () {
                  navigateToCart();
                },
                child: Container(
                  height: screenSize.height * 0.08, // Set a fixed height
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(10), // Add border radius
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.015,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip
                            .none, // Allow overflow for the Positioned widget
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            size: screenSize.width * 0.06,
                          ),
                          if (_cartItemCount > 0)
                            Positioned(
                              right:
                                  -6, // Adjust these values to position the badge correctly
                              top:
                                  -6, // Adjust these values to position the badge correctly
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$_cartItemCount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenSize.width *
                                        0.03, // Adjust font size as needed
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Cart',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 3),
            Flexible(
              fit: FlexFit.tight,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => OrderCart()),
                  );
                },
                child: Container(
                  height: screenSize.height * 0.08, // Set a fixed height
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(10), // Add border radius
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.015,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag,
                        color: Colors.black,
                        size: screenSize.width *
                            0.06, // Adjust icon size as needed
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Orders',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

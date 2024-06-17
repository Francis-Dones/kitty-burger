import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:kitty_burger_app/model/getCartAPI.dart';
import 'package:kitty_burger_app/model/global.dart';
import 'package:kitty_burger_app/model/productAPI.dart';
import 'package:kitty_burger_app/view/getcart.dart';
import 'package:kitty_burger_app/view/order.dart';
import 'package:kitty_burger_app/view/product.dart';

import 'home.dart';

class mainmenu extends StatefulWidget {
  final VoidCallback signOut;
  final String title;

  const mainmenu(this.signOut, {Key? key, required this.title})
      : super(key: key);

  @override
  _mainmenuState createState() => _mainmenuState();
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

  Item({
    required this.product_id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    required this.dateTime,
    this.isChecked = false,
    required this.availableOrder,
  });
}

class _mainmenuState extends State<mainmenu> {
  var sessionManager = SessionManager();
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

  String _saveURLdomain = "";
  String userProfileImage = "";
  String username = "";
  int _cartItemCount = 0;
  // Asynchronous function to fetch domain
  void globalDomain() async {
    String saveURLdomain = await globaldomain.insert_Domain();
    setState(() {
      _saveURLdomain = saveURLdomain;
    });
  }

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

  void _showSnackBar(String _text, bool _isSuccess) {
    print(_isSuccess);
    if (_isSuccess == true) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.green, content: Text(_text)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(_text)));
    }
  }

  late final bool enableFeedback;
  @override
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 3)); // 3-second delay
    sessionloginuser();
    globalDomain();
    _getCartItemCount();
    product();
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
            title: const Text("Connection Failed"),
            content: const Text("Please Connect Internet"),
            actions: <Widget>[
              TextButton(
                child: const Text("Close"),
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

  List<Item> productList = [];
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
            availableOrder: product.quantity);
      }).toList();

      setState(() {
        productList = itemList;
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

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

  void navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(),
      ),
    );
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

  void warning() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Wanna Exit?',
            style: TextStyle(color: Colors.blue), // Title text color
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'No',
                style: TextStyle(color: Colors.red), // Button text color
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.green), // Button text color
              ),
            ),
          ],
        );
      },
    ).then((exit) {
      if (exit == null) return;

      if (exit) {
        // user pressed Close button
        SystemNavigator.pop();
      } else {
        // user pressed No button
      }
    });
  }

  bool isActive = true;
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return WillPopScope(
        onWillPop: () async {
          warning();
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 234, 34, 147),
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white, // Change border color as needed
                      width: 2, // Change border width as needed
                    ),
                  ),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          "$_saveURLdomain/kitty_burger/public/images/users/$userProfileImage",
                        ),
                      ),
                      if (isActive) // Conditionally render the green dot if the account is active
                        Positioned(
                          top: 30, // Adjust the position of the dot as needed
                          left: 28,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color.fromARGB(255, 71, 255,
                                  77), // Change dot color as needed
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
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
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.1,
                    vertical: screenSize.height * 0.05,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 240, 245),
                              borderRadius: BorderRadius.circular(
                                  10), // Adjust the radius as needed
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ), // Adjust padding as needed
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ignore: prefer_const_constructors
                                Text(
                                  'Welcome To Kitty Burger!',
                                  style: const TextStyle(
                                    color: Color.fromARGB(
                                        255, 234, 34, 147), // Text color
                                    fontSize: 24,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Hi, ${username.isNotEmpty ? username : 'Guest'}',
                                  style: const TextStyle(
                                    color: Color.fromARGB(
                                        255, 234, 34, 147), // Text color
                                    fontSize: 24,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                    height:
                                        10), // Adding space between the texts
                                const Text(
                                  'Special food for you!',
                                  style: TextStyle(
                                    color: Color.fromARGB(
                                        255, 234, 34, 147), // Text color
                                    fontSize: 24,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      CarouselSlider(
                        options: CarouselOptions(
                          height: screenSize.height * 0.3,
                          aspectRatio: 16 / 9,
                          autoPlay: true,
                          enlargeCenterPage: true,
                        ),
                        items: productList.map((itemToAdd) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      20.0), // Adjust the radius as needed
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10.0,
                                      spreadRadius: 5.0,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      20.0), // Match the radius of the container
                                  child: Image.network(
                                    "$_saveURLdomain/kitty_burger/public/images/products/${itemToAdd.image}",
                                    fit: BoxFit.cover,
                                    width: 400, // Adjust the width as needed
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      const Padding(
                        padding: EdgeInsets.all(15),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 240,
                                  245), // Light pink background color
                              borderRadius: BorderRadius.circular(
                                  10), // Adjust the radius as needed
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(
                                  8.0), // Add padding inside the container for better spacing
                              child: Text(
                                "Craving a delicious, mouthwatering burger? Look no further! At Kitty Burger, "
                                "we bring you the finest, juiciest, and most satisfying burgers right to your fingertips.",
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 234, 34, 147), // Text color
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
          backgroundColor: const Color.fromARGB(255, 247, 178, 217),
        ));
  }
}

void main() {
  runApp(MyApp());
}

// Root widget of

// Root widget of the app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitty Burger',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: mainmenu(
        () {
          // Define the signOut callback function here
          print("User signed out");
        },
        title: 'Main Menu',
      ),
    );
  }
}

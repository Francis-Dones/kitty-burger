import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:kitty_burger_app/model/loginAPI.dart';
import 'package:kitty_burger_app/view/register.dart';

import 'main_menu.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<Homepage> createState() => _HomepageState();
}

enum LoginStatus { notSignIn, signIn }

class _HomepageState extends State<Homepage> {
  final TextEditingController emailController = TextEditingController();
  final _formKey1 = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final textFieldpassword = FocusNode();

  var _apiReturn;
  var Emailcontroller = TextEditingController()..text = '';
  var passwController = TextEditingController()..text = '';
  var _expirationdate_userID;

  bool _success = false;
  bool _isLoading = false;
  bool _obscured = true;
  bool _secureMode = false;

  // for snackbar
  void _showSnackBar(String _text, bool _isSuccess) {
    print(_isSuccess);
    if (_isSuccess == true) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.green, content: Text(_text)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(_text)));
    }
  } // end snack bar

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      if (textFieldpassword.hasPrimaryFocus)
        return; // If focus is on text field, don't unfocus
      textFieldpassword.canRequestFocus = false; // Prevents focus if tap on eye
    });
  }

  @override
  void initState() {
    super.initState();
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
      if (_formKey1.currentState!.validate()) {
        loginfunctionAPI();
      }
    }
  }

  void screenShotdisable() async {
    final secureModeToggle = !_secureMode;

    if (secureModeToggle == true) {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      print('sample');
    } else {
      await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      print('sample1');
    }

    setState(() {
      _secureMode = !_secureMode;
    });
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: const Text("Connection Failed"),
          content: const Text("Please Connect Internet or Select Offline Mode"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                SystemNavigator.pop();
              },
            ),
            TextButton(
              child: const Text("Offline Mode"),
              onPressed: () {
                Navigator.pop(context, true);
                setState(() {
                  _isLoading = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> loginfunctionAPI() async {
    var _userId = Emailcontroller.text.trim();
    var _password = passwController.text.trim();

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> loginDetails = {
      'username': _userId,
      'password': _password
    };

    try {
      Map<dynamic, dynamic> result =
          await LoginClass.loginFunctionApi(loginDetails);

      if (result['success'] == true) {
        _showSnackBar(result['message'], true);
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
      } else {
        _showSnackBar(result['message'], false);
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e", false);
    } finally {
      // Hide loading indicator
      setState(() {
        _isLoading = false;
      });
    }
  }

  void warning() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            'Wanna Exit?',
            style: TextStyle(color: Colors.blue), // Title text color
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'No',
                style: TextStyle(color: Colors.red), // Button text color
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          warning();
          return false;
        },
        child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 247, 178, 217),
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 234, 34, 147),
              automaticallyImplyLeading: false,
            ),
            resizeToAvoidBottomInset: false,
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    padding: const EdgeInsets.all(25),
                    child: Form(
                      key: _formKey1,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Container(
                              width: 300, // Match the image width
                              height: 100, // Match the image height
                              decoration: const BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 5),
                                    blurRadius:
                                        10, // Add blur radius for a smoother shadow
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    15), // Add border radius if needed
                                child: Image.asset(
                                  'lib/database/kittyburgerlogo.jpg',
                                  width: 300,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                          const Padding(
                            padding: EdgeInsets.all(10),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Username",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 108, 108, 124),
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: TextFormField(
                              controller: Emailcontroller,
                              textAlign: TextAlign.start,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Empty Username!";
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                labelText: "username",
                                isDense: true, // Reduces height a bit
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none, // No border
                                  borderRadius: BorderRadius.circular(
                                      12), // Apply corner radius
                                ),
                                filled: true, // Needed for adding a fill color
                                fillColor:
                                    const Color.fromARGB(255, 244, 239, 239),
                                prefixIcon:
                                    const Icon(Icons.contact_mail, size: 24),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 108, 108, 124),
                                    width: 2.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 234, 34, 147),
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(10),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Password",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 108, 108, 124),
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: TextFormField(
                              controller: passwController,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: _obscured,
                              focusNode: textFieldpassword,
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Empty Password!";
                                } else if (val.length < 5) {
                                  return "Password must be at least 5 characters long";
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                labelText: "password",
                                isDense: true, // Reduces height a bit
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none, // No border
                                  borderRadius: BorderRadius.circular(
                                      12), // Apply corner radius
                                ),
                                filled: true, // Needed for adding a fill color
                                fillColor:
                                    const Color.fromARGB(255, 244, 239, 239),
                                prefixIcon:
                                    const Icon(Icons.lock_rounded, size: 24),
                                suffixIcon: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 4, 0),
                                  child: GestureDetector(
                                    onTap: _toggleObscured,
                                    child: Icon(
                                      _obscured
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 108, 108, 124),
                                    width: 2.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 234, 34, 147),
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // End of Password Input
                          const Padding(
                            padding: EdgeInsets.all(15),
                          ),
                          //for login button
                          SizedBox(
                            width: 300, // Set the width to your desired value
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey1.currentState!.validate()) {
                                    loginfunctionAPI();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 234, 34, 147),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors
                                          .white), // Set text color to white
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 108, 108, 124),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const register(
                                        title: '',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Register Account",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 234, 34, 147)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )));
  }

  void signOut() {
    setState(() {
      _apiReturn = '';
    });
  }
}

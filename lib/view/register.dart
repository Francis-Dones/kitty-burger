// ignore_for_file: use_build_context_synchronously, avoid_print, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:kitty_burger_app/model/registerFunctionAPI.dart';
import 'package:kitty_burger_app/view/home.dart';
import 'package:kitty_burger_app/view/otp_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: camel_case_types
class register extends StatefulWidget {
  const register({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<register> createState() => _registerState();
}

enum LoginStatus { notSignIn, signIn }

class _registerState extends State<register> {
  var Emailcontroller = TextEditingController()..text = '';
  var passwController = TextEditingController()..text = '';

  var ContactNocontroller = TextEditingController()..text = '+63';
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController middlenameController = TextEditingController();
  final TextEditingController AddressController = TextEditingController();

  final TextEditingController emailController = TextEditingController();
  TextEditingController _dateInput = TextEditingController();
  TextEditingController Usernamecontroller = TextEditingController();

  final TextEditingController ConfirmPasswordontroller =
      TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final textFieldpassword = FocusNode();
  final _formKey1 = GlobalKey<FormState>();
  final textFieldpassword1 = FocusNode();

  DateTime _dateInputStarted = DateTime.now();
  DateTime _dateInputEnded = DateTime.now();

  String _dateOfSampling = '';
  String currentDate = DateFormat().format(DateTime.now());
  String printercurrentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String printercurrentTime = DateFormat('hh:mm a').format(DateTime.now());

  late List<CameraDescription>? _cameras;
  late CameraController _cameraController;
  bool _isLoading = true;
  XFile? _pictureFile;
  Uint8List? _imageBytes;
  // List<int>? _rawImageBytes;
  File? _fileImage;
  bool _isCameraOn = false;
  bool _isCaptureButtonDisabed = false;
  bool _isRetakeButtonDisabed = true;
  String _view = "";
  Map _vehicleTestData = {};
  Map _imageTestData = {};
  String _base64Image = "";

  Map<dynamic, dynamic> SaveDetailsUser = {};

  bool _success = false;

  bool _obscured = true;
  bool _obscured1 = true;
  bool _secureMode = false;

  var _apiReturn;
  var _expirationdate_userID;

  List<dynamic> _inspectionParameter = [];
  Map _arrayImages = {};
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
        return; // If focus is on text field, dont unfocus
      textFieldpassword.canRequestFocus = false; // Prevents focus if tap on eye
    });
  }

  void _toggleObscured1() {
    setState(() {
      _obscured1 = !_obscured1;
      if (textFieldpassword1.hasPrimaryFocus)
        return; // If focus is on text field, dont unfocus
      textFieldpassword1.canRequestFocus =
          false; // Prevents focus if tap on eye
    });
  }

  @override
  void initState() {
    startCamera();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
      if (!_formKey1.currentState!.validate()) {
        // Form validation failed
        // Handle validation failure here, if needed
      } else {
        // Form validation passed
        RegisterFunctionSave();
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

  // ignore: unused_element
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

  void startCamera() async {
    _imageTestData = await SessionManager().get("imageTestData");
    String _savedBase64Image = "";

    if (_savedBase64Image != "") {
      setState(() {
        _base64Image = _savedBase64Image;
        _imageBytes = base64Decode(_savedBase64Image);
        _isCaptureButtonDisabed = true;
        _isRetakeButtonDisabed = false;
      });
    }

    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras![0],
      ResolutionPreset.max,
    );
    await _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((e) {
      print(e);
    });
  }

  void showCamera() async {
    if (_isCameraOn == true) {
      bool _hasImage = false;
      Uint8List? _tempImageBytes;
      // List<int>? _tempRawImageBytes;
      File? _tempFileImage;

      List<CameraDescription> cameras = await availableCameras();
      CameraDescription frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front);
      _cameraController =
          CameraController(frontCamera, ResolutionPreset.medium);
      await _cameraController.initialize();

      return await showDialog(
        barrierColor: Colors.black,
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (stfContext, stfSetState) {
            if (!_cameraController.value.isInitialized) {
              return const SizedBox(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return Column(
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: CameraPreview(_cameraController),
                    )),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: _hasImage
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 5, style: BorderStyle.solid)),
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                width: 75,
                                height: 75,
                                child: FloatingActionButton(
                                  focusColor: Colors.white54,
                                  backgroundColor: Colors.white,
                                  onPressed: () async {
                                    stfSetState(() {
                                      _hasImage = false;
                                    });
                                    _cameraController.resumePreview();
                                  },
                                  child: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 50,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 5, style: BorderStyle.solid)),
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                width: 75,
                                height: 75,
                                child: FloatingActionButton(
                                  focusColor: Colors.white54,
                                  backgroundColor: Colors.white,
                                  onPressed: () async {
                                    setState(() {
                                      _fileImage = _tempFileImage;
                                      _imageBytes = _tempImageBytes;
                                      // _rawImageBytes = _tempRawImageBytes;
                                      _isCaptureButtonDisabed = true;
                                      _isRetakeButtonDisabed = false;
                                    });
                                    _cameraController.resumePreview();
                                    Navigator.pop(context);
                                  },
                                  child: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 50,
                                  ),
                                ),
                              )
                            ],
                          )
                        : Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    width: 5, style: BorderStyle.solid)),
                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            width: 75,
                            height: 75,
                            child: FloatingActionButton(
                              focusColor: Colors.white54,
                              backgroundColor: Colors.white,
                              onPressed: () async {
                                _pictureFile =
                                    await _cameraController.takePicture();
                                _cameraController.pausePreview();
                                List<int> imageBytes =
                                    await _pictureFile!.readAsBytes();
                                File file2 = File(_pictureFile!.path);

                                img.Image? originalImage =
                                    img.decodeImage(imageBytes);
                                img.Image fixedImage =
                                    img.flipHorizontal(originalImage!);
                                fixedImage = img.copyResize(fixedImage,
                                    width: 640, height: 480);
                                File _fixedFile = await file2.writeAsBytes(
                                  img.encodeJpg(fixedImage),
                                  flush: true,
                                );

                                List<int> _rawImageBytes1 =
                                    await _fixedFile.readAsBytes();

                                setState(() {
                                  _base64Image = base64Encode(_rawImageBytes1);
                                });

                                Uint8List _fixedBytes =
                                    base64Decode(_base64Image);

                                stfSetState(() {
                                  _tempFileImage = _fixedFile;
                                  // _tempImage = _fixedFile;
                                  _tempImageBytes = _fixedBytes;
                                  // _tempRawImageBytes = _rawImageBytes1;
                                  _hasImage = true;
                                });

                                // Navigator.pop(context);
                              },
                              // Adjust this alignment as needed
                              child: const SizedBox(
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  color: Color.fromARGB(255, 175, 0, 149),
                                  size: 50,
                                ),
                              ),
                            ),
                          )),
              ],
            );
          });
        },
      );
    } else {
      Navigator.pop(context); //pop dialog
    }
  }

  // // ignore: non_constant_identifier_names
  // Future<void> RegisterFunctionSave() async {
  //   setState(() async {
  //     SaveDetailsUser = {
  //       'last_name': lastnameController.text,
  //       'first_name': firstnameController.text,
  //       'middle_name': middlenameController.text,
  //       'address': AddressController.text,
  //       'birth_date': _dateInput.text,
  //       'email': Emailcontroller.text,
  //       'mobile': ContactNocontroller.text,
  //       'username': Emailcontroller.text,
  //       'password': ConfirmPasswordontroller.text,
  //       'image': _base64Image
  //     };
  //     Map<dynamic, dynamic> _result =
  //         await registerSaveINfoClass.RegisterData(SaveDetailsUser);

  //     if (_result['code'] == "1") {
  //       _showSnackBar(_result['message'], true);
  //     } else {
  //       _showSnackBar(_result['message'], false);
  //     }
  //   });
  // }

  void _onLoading() async {
    if (_isLoading == true) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context2) {
          return Container(
            color: const Color.fromARGB(90, 0, 55, 175),
            width: double.maxFinite,
            height: double.maxFinite,
            child: const Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 6,
                ),
              ),
            ),
          );
        },
      );
    } else {
      Navigator.pop(context); //pop dialog
    }
  }

  // ignore: non_constant_identifier_names
  Future<void> RegisterFunctionSave() async {
    _onLoading();
    setState(() async {
      // Constructing the user details to be saved
      Map<String, dynamic> userDetails = {
        'last_name': lastnameController.text,
        'first_name': firstnameController.text,
        'middle_name': middlenameController.text,
        'address': AddressController.text,
        'birth_date': _dateInput.text,
        'email': Emailcontroller.text,
        'mobile': ContactNocontroller.text,
        'username': Usernamecontroller.text,
        'password': ConfirmPasswordontroller.text,
        'image': _base64Image
      };

      try {
        // Invoking the registration process
        Map<dynamic, dynamic> result =
            await registerSaveINfoClass.RegisterData(userDetails);

        saveSessionData(String key, String value) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString(key, value);
        }

        // Handling the registration outcome
        if (result['success'] == true) {
          _showSnackBar(result['message'], true);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const OtpPage(
                    title: '',
                  )));

          saveSessionData('username', userDetails['username']);
        } else {
          // Handle other cases where success might be false or not provided
          _showSnackBar(result['message'], false);
        }
      } catch (e) {
        _showSnackBar("An error occurred: $e", false);
      }
    });
  }

  void saveImage() async {
    RegisterFunctionSave();
  }

  void imageUploadConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (stfContext, stfSetState) {
          return AlertDialog(
            title: const Text("Are you Sure Save Image?"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              TextButton(
                onPressed: () => Navigator.pop(context, false), // passing false
                // ignore: prefer_const_constructors
                child: Text('Cancel'),
              ),
              TextButton(
                child: const Text("Confirm"),
                onPressed: () {
                  // ignore: unnecessary_null_comparison
                  if (_base64Image != "" || _base64Image != null) {
                    setState(() {
                      _isLoading = true;
                    });
                    _onLoading();
                    Future.delayed(const Duration(seconds: 1), () {
                      saveImage();
                    });
                  }
                },
              ),
            ],
            icon: const Icon(Icons.directions_car_sharp,
                color: Colors.black, size: 35),
            contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            actionsPadding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
          );
        });

        // return object of type Dialog
      },
    );
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
              title: const Text(
                'Kitty Burger',
                style: TextStyle(
                  color: Colors.white, // You can adjust the color as needed
                  fontSize: 30, // Adjust the font size
                  fontStyle: FontStyle.italic, // Set the font style to italic
                ),
              ),
            ),
            resizeToAvoidBottomInset: false,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: _formKey1,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Stack(children: [
                        _imageBytes != null
                            ? AspectRatio(
                                aspectRatio: 4 / 3,
                                child: Image.memory(
                                  _imageBytes!,
                                  fit: BoxFit.fill,
                                ),
                              )
                            : AspectRatio(
                                aspectRatio: 4 / 3,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 4, color: Colors.blueGrey),
                                  ),
                                  child: Icon(
                                    Icons.people,
                                    color: Colors.blueGrey,
                                    size:
                                        MediaQuery.of(context).size.width * .6,
                                  ),
                                ),
                              ),
                      ]),
                    ),
                    const Center(
                      child: Align(
                        child: Text(
                          "User Profile",
                          style: TextStyle(
                            color: Color.fromARGB(255, 108, 108, 124),
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: _isCaptureButtonDisabed
                                    ? null
                                    : () {
                                        setState(() {
                                          _isCameraOn = true;
                                        });
                                        showCamera();
                                      },
                                style: ButtonStyle(
                                    backgroundColor: _isCaptureButtonDisabed
                                        ? MaterialStateProperty.all(
                                            const Color.fromARGB(
                                                55, 234, 34, 147),
                                          )
                                        : MaterialStateProperty.all(
                                            const Color.fromARGB(
                                                255, 234, 34, 147),
                                          ),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      // side: BorderSide(color: Colors.red)
                                    ))),

                                child: const Text(
                                  'CAPTURE',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 241, 241, 243),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                // ignore: sort_child_properties_last
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: _isRetakeButtonDisabed
                                    ? null
                                    : () {
                                        setState(() {
                                          _isCameraOn = true;
                                        });
                                        showCamera();
                                      },
                                style: ButtonStyle(
                                    backgroundColor: _isRetakeButtonDisabed
                                        ? MaterialStateProperty.all(
                                            const Color.fromARGB(
                                                55, 234, 34, 147),
                                          )
                                        : MaterialStateProperty.all(
                                            const Color.fromARGB(
                                                255, 234, 34, 147),
                                          ),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      // side: BorderSide(color: Colors.red)
                                    ))),
                                child: const Text(
                                  'RETAKE',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 241, 241, 243),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                // ignore: sort_child_properties_last
                              ),
                            ),
                          ),

                          // ignore: avoid_unnecessary_containers
                        ],
                      ),
                    ),
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "First Name",
                          style: TextStyle(
                            color: Color.fromARGB(255, 108, 108, 124),
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: TextFormField(
                        controller: firstnameController,
                        textAlign: TextAlign.start,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter First Name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: "First Name",
                          isDense: true, // Reduces height a bit
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none, // No border
                            borderRadius: BorderRadius.circular(
                                12), // Apply corner radius
                          ),
                          filled: true, // Needed for adding a fill color
                          fillColor: const Color.fromARGB(255, 244, 239, 239),
                          prefixIcon:
                              const Icon(Icons.people_alt_rounded, size: 24),
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
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Last Name",
                          style: TextStyle(
                            color: Color.fromARGB(255, 108, 108, 124),
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: TextFormField(
                        controller: lastnameController,
                        textAlign: TextAlign.start,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Last Name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: "LastName",
                          isDense: true, // Reduces height a bit
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none, // No border
                            borderRadius: BorderRadius.circular(
                                12), // Apply corner radius
                          ),
                          filled: true, // Needed for adding a fill color
                          fillColor: const Color.fromARGB(255, 244, 239, 239),
                          prefixIcon:
                              const Icon(Icons.people_alt_rounded, size: 24),
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
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Middle Name",
                          style: TextStyle(
                            color: Color.fromARGB(255, 108, 108, 124),
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: TextFormField(
                        controller: middlenameController,
                        textAlign: TextAlign.start,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Middle Name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: "MiddleName",
                          isDense: true, // Reduces height a bit
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none, // No border
                            borderRadius: BorderRadius.circular(
                                12), // Apply corner radius
                          ),
                          filled: true, // Needed for adding a fill color
                          fillColor: const Color.fromARGB(255, 244, 239, 239),
                          prefixIcon:
                              const Icon(Icons.people_alt_rounded, size: 24),
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
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Address",
                          style: TextStyle(
                            color: Color.fromARGB(255, 108, 108, 124),
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: TextFormField(
                        controller: AddressController,
                        textAlign: TextAlign.start,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Middle Name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: "Address",
                          isDense: true, // Reduces height a bit
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none, // No border
                            borderRadius: BorderRadius.circular(
                                12), // Apply corner radius
                          ),
                          filled: true, // Needed for adding a fill color
                          fillColor: const Color.fromARGB(255, 244, 239, 239),
                          prefixIcon: const Icon(Icons.home, size: 24),
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
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Date of Birth",
                          style: TextStyle(
                            color: Color.fromARGB(255, 108, 108, 124),
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        controller: _dateInput,

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Select Date';
                          }
                          return null;
                        },
                        //editing controller of this TextField
                        decoration: const InputDecoration(
                            isDense: true,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 12.0),
                            filled: true, // Needed for adding a fill color
                            fillColor: Color.fromARGB(255, 244, 239, 239),
                            prefixIcon: Icon(Icons.date_range, size: 24),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 108, 108, 124),
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 234, 34, 147),
                                  width: 1.0),
                            ),
                            hintText: "YYYY/MM/DD"),
                        readOnly: true,

                        //set it true, so that user will not able to edit text
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1950),
                            //DateTime.now() - not to allow to choose before today.
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color.fromARGB(
                                        255, 234, 34, 149), // <-- SEE HERE
                                    onPrimary: Color.fromARGB(
                                        255, 241, 242, 245), // <-- SEE HERE
                                    onSurface: Color.fromARGB(
                                        255, 234, 34, 149), // <-- SEE HERE
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color.fromARGB(255,
                                          234, 34, 141), // button text color
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (pickedDate != null) {
                            print(
                                pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                            print(
                                formattedDate); //formatted date output using intl package =>  2021-03-16
                            setState(() {
                              _dateInput.text =
                                  formattedDate; //set output date to TextField value.
                            });
                          } else {}
                          // ignore: unused_label
                        },
                      ),
                    ),
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Email",
                          style: TextStyle(
                            color: Color.fromARGB(255, 108, 108, 124),
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: TextFormField(
                        controller: Emailcontroller,
                        textAlign: TextAlign.start,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Email is Required';
                          }
                          if (!RegExp(
                                  r"^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$")
                              .hasMatch(value)) {
                            return 'Please enter a valid Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: "Email",
                          isDense: true, // Reduces height a bit
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none, // No border
                            borderRadius: BorderRadius.circular(
                                12), // Apply corner radius
                          ),
                          filled: true, // Needed for adding a fill color
                          fillColor: const Color.fromARGB(255, 244, 239, 239),
                          prefixIcon: const Icon(Icons.contact_mail, size: 24),
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
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Contact No",
                          style: TextStyle(
                            color: Color.fromARGB(255, 108, 108, 124),
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: TextFormField(
                        controller: ContactNocontroller,
                        maxLength: 12,
                        textAlign: TextAlign.start,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Cellphone No';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: "Contact No",
                          isDense: true, // Reduces height a bit
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none, // No border
                            borderRadius: BorderRadius.circular(
                                12), // Apply corner radius
                          ),
                          filled: true, // Needed for adding a fill color
                          fillColor: const Color.fromARGB(255, 244, 239, 239),
                          prefixIcon: const Icon(Icons.contact_phone, size: 24),
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
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Username",
                          style: TextStyle(
                            color: Color.fromARGB(255, 108, 108, 124),
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: TextFormField(
                        controller: Usernamecontroller,
                        maxLength: 12,
                        textAlign: TextAlign.start,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Username';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: "Username",
                          isDense: true, // Reduces height a bit
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none, // No border
                            borderRadius: BorderRadius.circular(
                                12), // Apply corner radius
                          ),
                          filled: true, // Needed for adding a fill color
                          fillColor: const Color.fromARGB(255, 244, 239, 239),
                          prefixIcon: const Icon(Icons.people, size: 24),
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
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Password",
                          style: TextStyle(
                            color: Color.fromARGB(255, 108, 108, 124),
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: TextFormField(
                        controller: passwController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _obscured,
                        focusNode: textFieldpassword,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Please input Remarks before Upload";
                          } else if (val.length < 5) {
                            return "Remarks must be atleast 5 characters long";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior
                              .never, //Hides label on focus or if filled
                          labelText: "Password",
                          filled: true, // Needed for adding a fill color
                          fillColor: const Color.fromARGB(255, 244, 239, 239),
                          isDense: true, // Reduces height a bit
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none, // No border
                            borderRadius: BorderRadius.circular(
                                12), // Apply corner radius
                          ),
                          prefixIcon:
                              const Icon(Icons.password_rounded, size: 24),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
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
                        ),
                      ),
                    ),
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Confirm Password",
                          style: TextStyle(
                            color: Color.fromARGB(255, 108, 108, 124),
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: TextFormField(
                        controller: ConfirmPasswordontroller,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _obscured1,
                        focusNode: textFieldpassword1,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Empty';
                          }
                          if (val != passwController.text) {
                            return 'Not Match';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior
                              .never, //Hides label on focus or if filled
                          labelText: "ConfirmPassword",
                          filled: true, // Needed for adding a fill color
                          fillColor: const Color.fromARGB(255, 244, 239, 239),
                          isDense: true, // Reduces height a bit
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none, // No border
                            borderRadius: BorderRadius.circular(
                                12), // Apply corner radius
                          ),
                          prefixIcon:
                              const Icon(Icons.confirmation_number, size: 24),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                            child: GestureDetector(
                              onTap: _toggleObscured1,
                              child: Icon(
                                _obscured1
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Homepage(
                                              title: 'home',
                                            )),
                                  );
                                },
                                style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all(Colors.red),
                                    shape: WidgetStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      // side: BorderSide(color: Colors.red)
                                    ))),

                                child: const Text(
                                  'CANCEL',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 241, 241, 243),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                // ignore: sort_child_properties_last
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (!_formKey1.currentState!.validate()) {
                                    // Form validation failed
                                    // Handle validation failure here, if needed
                                  } else {
                                    // Form validation passed
                                    RegisterFunctionSave();
                                  }
                                },
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.green),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      // side: BorderSide(color: Colors.red)
                                    ))),
                                child: const Text(
                                  'SAVE',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 241, 241, 243),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                // ignore: sort_child_properties_last
                              ),
                            ),
                          ),

                          // ignore: avoid_unnecessary_containers
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }

  void signOut() {}
}

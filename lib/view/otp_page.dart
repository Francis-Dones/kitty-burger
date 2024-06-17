import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:kitty_burger_app/model/resendOtpAPI.dart';
import 'package:kitty_burger_app/model/verifyAPI.dart';
import 'package:kitty_burger_app/view/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  int _start = 60; // Countdown start value in seconds
  bool _timerRunning = true;
  late Timer _timer;
  bool _isLoading = false;
  bool _sendButtonEnabled = true;

  void startTimer() {
    setState(() {
      _timerRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _timerRunning = false;
          _sendButtonEnabled = false;
          // Disable the send button
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  bool isOtpFieldEnabled() {
    return _timerRunning;
  }

  Future<String?> getSessionData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  void _showSnackBar(String _text, bool _isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _isSuccess ? Colors.green : Colors.red,
        content: Text(_text),
      ),
    );
  }

  String enteredVerificationCode = '';

  void verify() async {
    String? username = await getSessionData('username');

    Map<String, dynamic> verifyDetails = {
      'username': username,
      'verification_code': enteredVerificationCode,
    };

    try {
      Map<dynamic, dynamic> result =
          await verifyClass.VerifyData(verifyDetails);

      if (result['success'] == true) {
        _showSnackBar(result['message'], true);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const Homepage(title: ''),
        ));
      } else {
        _showSnackBar(result['message'], false);
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e", false);
    }
  }

  void resendOtp() async {
    String? username = await getSessionData('username');

    Map<String, dynamic> resendotp = {
      'username': username,
    };

    try {
      Map<dynamic, dynamic> result = await resendClass.resendOtAPI(resendotp);

      if (result['success'] == true) {
        _showSnackBar(result['message'], true);
      } else {
        _showSnackBar(result['message'], false);
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e", false);
    }
  }

  void resendOTP() {
    setState(() {
      _start = 60;
      _sendButtonEnabled = true; // Enable the send button
    });
    startTimer();
    resendOtp();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 178, 217),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 234, 34, 147),
        automaticallyImplyLeading: false,
        title: const Text(
          'Kitty Burger',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(20), // Reduced padding for better spacing
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'OTP ONE TIME',
              style: TextStyle(
                color: Color.fromARGB(255, 7, 7, 7),
                fontSize: 30,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(
                height: 20), // Added spacing between title and OTP field
            OtpTextField(
              numberOfFields: 6,
              enabled: isOtpFieldEnabled(),
              borderColor: const Color(0xFF512DA8),
              showFieldAsBox: true,
              onCodeChanged: (String code) {},
              onSubmit: (String verificationCode) {
                setState(() {
                  enteredVerificationCode = verificationCode;
                });
              },
            ),
            const SizedBox(height: 20), // Added spacing below OTP field
            _timerRunning
                ? Text("$_start seconds remaining")
                : TextButton(
                    onPressed: resendOTP,
                    child: const Text(
                      "Resend OTP",
                      style: TextStyle(color: Colors.blue, fontSize: 15),
                    ),
                  ),
            const SizedBox(height: 20), // Added spacing below Resend OTP button
            ElevatedButton(
              onPressed: _sendButtonEnabled
                  ? verify
                  : null, // Disable the button when timer runs out
              child: const Text("Send"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

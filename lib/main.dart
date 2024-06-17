import 'package:flutter/material.dart';
import 'package:kitty_burger_app/view/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: unused_label
    backgroundColor:
    const Color.fromARGB(255, 85, 4, 236);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'title',
        theme: ThemeData(
          primaryColor: const Color.fromARGB(255, 2, 23, 120),
        ),
        home: const Homepage(
          title: 'home',
        ));
  }
}

void signOut() {}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vitappflutterweb/src/Screens/HomeScreen.dart';
import 'package:vitappflutterweb/src/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIT App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'mont',
        primaryColor: kPrimaryColor,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }
}

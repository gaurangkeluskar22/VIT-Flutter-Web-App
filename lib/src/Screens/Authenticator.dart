import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vitappflutterweb/src/Screens/HomeScreen.dart';
import 'SignInSignUpPage.dart';

class Authenticator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AuthenticatorState();
}

class _AuthenticatorState extends State<Authenticator> {
  User _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (_user != null) {
      Future(() {
        pushToHomePage();
      });
    } else {
      Future(() {
        pushToSignInSignUp();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  void pushToSignInSignUp() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignInSignUpPage()));
  }

  void pushToHomePage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }
}

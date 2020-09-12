import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vitappflutterweb/src/Widgets/Animation.dart';
import 'package:vitappflutterweb/src/constants.dart';
import 'package:vitappflutterweb/main.dart';

void _signOut(context) async {
  try {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, BouncyPageRoute(widget: MyApp()));
  } catch (e) {
    print(e);
  }
}

header(
  context, {
  bool isAppTitle = false,
  String titleText,
  removeBack = false,
  isCenterTitle = false,
  isLogout = false,
  bold = false,
}) {
  return AppBar(
      title: Text(
        isAppTitle ? 'VIT' : titleText,
        style: TextStyle(
            fontSize: isAppTitle ? 30 : 22,
            color: Colors.white,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal),
      ),
      backgroundColor: kPrimaryColor,
      actions: isLogout
          ? <Widget>[
              FlatButton(
                child: Text(
                  'Sign out',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => _signOut(context),
              )
            ]
          : null,
      centerTitle: isCenterTitle);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boom_menu/flutter_boom_menu.dart';
import 'package:vitappflutterweb/src/Screens/AddNotes.dart';
import 'package:vitappflutterweb/src/Screens/AddNotices.dart';
import 'package:vitappflutterweb/src/Screens/NotesSection.dart';
import 'TimeLine.dart';
import 'Authenticator.dart';
import 'package:vitappflutterweb/src//Widgets/header.dart';
import 'package:vitappflutterweb/src/constants.dart';

final postRef = FirebaseFirestore.instance.collection('posts');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
final StorageReference storageRef = FirebaseStorage.instance.ref();
final notesRef = FirebaseFirestore.instance.collection('notes');
final subjectsRef = FirebaseFirestore.instance.collection('subjects');
final departmentRef = FirebaseFirestore.instance.collection('departments');

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget firstWidget() {
    return TimeLine();
  }

  Widget secondWidget() {
    return NotesSection();
  }

  Widget initWidget;
  @override
  void initState() {
    super.initState();
    initWidget = firstWidget();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true, isCenterTitle: true),
      body: initWidget,
      drawer: Drawer(child: buildSideBar()),
      floatingActionButton: FirebaseAuth.instance.currentUser != null
          ? BoomMenu(
              animatedIcon: AnimatedIcons.menu_close,
              child: Text('+'),
              backgroundColor: kPrimaryColor,
              animatedIconTheme: IconThemeData(size: 22.0),
              overlayColor: Colors.black,
              overlayOpacity: 0.7,
              children: [
                MenuItem(
                  child: Icon(
                    Icons.filter_frames,
                    color: Colors.white,
                  ),
                  title: 'Notice',
                  subtitle: 'Add Notice',
                  titleColor: Colors.white,
                  subTitleColor: Colors.white,
                  backgroundColor: Color(0xff0984e3),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddNotice()),
                  ),
                ),
                MenuItem(
                  child: Icon(
                    Icons.library_books,
                    color: Colors.white,
                  ),
                  title: 'Notes',
                  titleColor: Colors.white,
                  subtitle: 'Add Notes',
                  subTitleColor: Colors.white,
                  backgroundColor: Color(0xffe84393),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddNotes()),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  ListView buildSideBar() {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Center(
              child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: Image.asset(
                  'assets/images/profile.jpg',
                  height: 100.0,
                ),
              ),
              SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    FirebaseAuth.instance.currentUser != null
                        ? 'Admin'
                        : 'Student',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  FirebaseAuth.instance.currentUser != null
                      ? Row(
                          children: [
                            SizedBox(width: 5.0),
                            Icon(Icons.stars, color: Colors.white),
                          ],
                        )
                      : Container()
                ],
              ),
            ],
          )),
          decoration: BoxDecoration(
            color: kPrimaryColor,
          ),
        ),
        getTile(Icons.filter_frames, 'Notice',
            function: () => {
                  setState(() {
                    initWidget = firstWidget();
                  }),
                  Navigator.pop(context),
                }),
        Divider(),
        getTile(Icons.library_books, 'Notes',
            function: () => {
                  setState(() {
                    initWidget = secondWidget();
                  }),
                  Navigator.pop(context),
                }),
        Divider(),
        FirebaseAuth.instance.currentUser != null
            ? getTile(Icons.exit_to_app, 'Sign Out', function: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              })
            : getTile(Icons.account_circle, 'Admin Login', function: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Authenticator()));
              }),
        Divider(),
      ],
    );
  }

  GestureDetector getTile(IconData icon, String text, {Function function}) {
    return GestureDetector(
      onTap: function,
      child: ListTile(
        leading: Icon(
          icon,
          color: kPrimaryColor,
        ),
        title: Text(
          text,
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}

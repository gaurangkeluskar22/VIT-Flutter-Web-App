import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vitappflutterweb/src/Screens/DepartmentNotes.dart';
import 'package:vitappflutterweb/src/Screens/HomeScreen.dart';
import 'package:vitappflutterweb/src/Widgets/header.dart';
import 'package:vitappflutterweb/src/Widgets/loading.dart';

import '../constants.dart';

List<DocumentSnapshot> _list;
String yearValue;

class NotesSection extends StatefulWidget {
  @override
  _NotesSectionState createState() => _NotesSectionState();
}

class _NotesSectionState extends State<NotesSection> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: adminScreen());
  }

  Widget adminScreen() {
    return Scaffold(
      key: _scaffoldKey,
      body: StreamBuilder(
        stream: departmentRef.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return loadingScreen();
          }
          _list = snapshot.data.docs;
          List<Padding> _listTiles = [];
          _list.forEach(
            (DocumentSnapshot documentSnapshot) {
              _listTiles.add(
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: GestureDetector(
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DepartmentNotes(dept: documentSnapshot.id)),
                      ),
                    },
                    child: Container(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(
                                color: kPrimaryColor.withOpacity(0.6),
                                width: 0.7,
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xff9921E8).withOpacity(0.9),
                                  kPrimaryColor
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              '${documentSnapshot.id}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );

          return GridView.count(
            crossAxisCount: 2,
            children: _listTiles,
            physics: BouncingScrollPhysics(),
          );
        },
      ),
    );
  }
}

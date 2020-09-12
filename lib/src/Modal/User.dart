import 'package:cloud_firestore/cloud_firestore.dart';

class VITUser {
  final String id;
  final String displayName;
  final bool admin;

  VITUser({this.id, this.displayName, this.admin});

  // Named Constructor
  factory VITUser.fromDocument(DocumentSnapshot doc) {
    return VITUser(
      id: doc.data()['id'],
      displayName: doc.data()['displayName'],
      admin: doc.data()['admin'],
    );
  }
}

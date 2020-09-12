import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final adminRef = FirebaseFirestore.instance.collection('admin');

abstract class AuthFunc {
  Future<String> signIn(String email, String password);
  Future<String> signUp(String email, String password);
  Future<User> getCurrentUser();
  Future sendPasswordResetLink(String email);
}

class MyAuth implements AuthFunc {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<User> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<String> signIn(String email, String password) async {
    try {
      var user = (await _firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      return user.uid;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> signUp(String email, String password) async {
    try {
      var user = (await _firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      await adminRef.doc(user.uid).set({
        'id': user.uid,
        'email': user.email,
        'timestamp': DateTime.now(),
        'displayName':
            '${user.email.split('@')[0].split('.')[0]} ${user.email.split('@')[0].split('.')[1]}',
      });

      return user.uid;
    } catch (e) {
      return null;
    }
  }

  @override
  Future sendPasswordResetLink(String email) {
    try {
      return _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      return null;
    }
  }
}

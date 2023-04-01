import 'package:chat_app/models/users.dart';
import 'package:chat_app/screens/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

Future<User?> createAccout(String name, String password, String email) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  try {
    User? user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;
    if (user != null) {
      print('Sign up Sucessfully!');
      MyUser myUser = MyUser(
          status: "Unavailable",
          name: name,
          id: _auth.currentUser!.uid,
          email: email,
          password: password);
      user.updateDisplayName(name);
      await _firestore.collection('users').doc(myUser.id).set(myUser.toJson());
      return user;
    } else {
      print('Cannot Sign up');
      return user;
    }
  } catch (e) {
    print(e);
    return null;
  }
}

Future<User?> signIn(String email, String password) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  try {
    User? user = (await _auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;
    if (user != null) {
      print('Sign in Sucessfully!');
      return user;
    } else {
      print('Cannot Sign in');
      return user;
    }
  } catch (e) {
    print(e);
    return null;
  }
}

Future logOut() async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  try {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .update({'status': 'Offline'});
    await _auth.signOut();
    print('Logout Sucessfully!');

    Get.offAll(LoginPage());
  } catch (e) {
    print("Error $e");
  }
}

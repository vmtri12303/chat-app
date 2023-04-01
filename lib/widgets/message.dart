import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyMessage extends StatelessWidget {
  const MyMessage({
    Key? key,
    required FirebaseAuth auth,
    required this.size,
    required this.map,
  })  : _auth = auth,
        super(key: key);

  final FirebaseAuth _auth;
  final Size size;
  final Map<String, dynamic> map;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      alignment: map['sendby'] == _auth.currentUser!.displayName
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.blue,
        ),
        child: Text(
          map['message'],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

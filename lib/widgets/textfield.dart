import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({
    Key? key,
    required this.size,
    required this.hintText,
    required this.icon,
    required this.textController,
  }) : super(key: key);

  final Size size;
  final String hintText;
  final Icon icon;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: size.width / 20, vertical: size.height / 55),
      child: TextField(
        obscureText: hintText == 'Password' ? true : false,
        controller: textController,
        decoration: InputDecoration(
            prefixIcon: icon,
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }
}

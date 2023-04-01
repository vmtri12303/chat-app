import 'package:flutter/material.dart';

class ImageDetail extends StatelessWidget {
  final String imageUrl;

  const ImageDetail({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(),
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.white,
        child: Image.network(imageUrl),
      ),
    );
  }
}

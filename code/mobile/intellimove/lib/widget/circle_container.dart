import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CircleContainer extends StatelessWidget {
  const CircleContainer({Key? key, required this.text}) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Color(0xFF003401),
          shape: BoxShape.circle,
          border: Border.all(
            color: Color(0xFF74ae01), // Border color
            width: 8.0, // Border width
          ),
        ),
        child: Center(child: AutoSizeText(text, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 40,color: Colors.white),)),
      ),
    );
  }
}

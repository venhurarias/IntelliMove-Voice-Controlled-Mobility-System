import 'package:flutter/material.dart';

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.brightness_1,
          size: 8.0, // Size of the bullet
          color: Colors.white, // Color of the bullet
        ),
        SizedBox(width: 8.0), // Space between bullet and text
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.normal,
                color: Colors.white
            ),
          ),
        ),
      ],
    );
  }
}
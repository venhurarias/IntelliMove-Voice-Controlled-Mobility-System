import 'package:flutter/material.dart';

class HelpSteps extends StatelessWidget {
  const HelpSteps({Key? key, required this.title, required this.description}) : super(key: key);
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
        Text(description,textAlign: TextAlign.justify, style: TextStyle(color: Colors.white,fontSize: 16),),

      ],
    );
  }
}

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';


class MyButton extends StatelessWidget {
  const MyButton({super.key, required this.text, this.onPressed});
  final String text;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                30.0), // Adjust the radius as needed
          ),
          padding: EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 15.0), // Adjust the padding as needed
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: AutoSizeText(text,maxLines: 1,textAlign: TextAlign.center, style: TextStyle(fontSize: 18),))
          ],
        ),
      ),
    );
  }
}

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

import '../widget/my_button.dart';

class JoystickPage extends StatefulWidget {
  const JoystickPage({super.key, required this.connection});

  final BluetoothConnection? connection;

  @override
  State<JoystickPage> createState() => _JoystickState();
}

class _JoystickState extends State<JoystickPage> {
  int page = 0;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery
        .of(context)
        .padding
        .top;
    final bottomPadding = MediaQuery
        .of(context)
        .padding
        .bottom;
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF227acb)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset("assets/images/icon.png", width: 50, fit: BoxFit.cover),
                  const SizedBox(width: 10),
                  const Text("IntelliMove", style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 20,),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Joystick Control",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),)),
              Expanded(child: SizedBox()),
              Joystick(
                base: JoystickBase(decoration: JoystickBaseDecoration(color: Colors.black, drawOuterCircle: false,), arrowsDecoration: JoystickArrowsDecoration(color: Colors.white,),),
                listener: (details) {
                  final x = details.x;
                  final y = details.y;

                  String? direction;

                  if (x.abs() < 0.2 && y.abs() < 0.2) {
                    direction = "0";
                  } else if (y < -0.5 && x.abs() < 0.5) {
                    direction = "w";
                  } else if (y > 0.5 && x.abs() < 0.5) {
                    direction = "s";
                  } else if (x < -0.5 && y.abs() < 0.5) {
                    direction = "a";
                  } else if (x > 0.5 && y.abs() < 0.5) {
                    direction = "d";
                  }

                  if (direction != null) {
                    widget.connection?.writeString(direction);
                    print("Direction: $direction");
                  }

                },),
              SizedBox(height: 10,),
              Align(
                  alignment: Alignment.center,
                  child: Text("Use to control the wheelchair manually.",style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 16),)),
              Expanded(child: SizedBox()),
              SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}





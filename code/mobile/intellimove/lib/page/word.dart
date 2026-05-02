import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';

import '../widget/my_button.dart';

class Word extends StatefulWidget {
  const Word({Key? key,required this.connection}) : super(key: key);
  final BluetoothConnection? connection;

  @override
  State<Word> createState() => _WordState();
}

class _WordState extends State<Word> {
  int page = 0;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff92d500),
              Color(0xFF003000),
            ],
            stops: [0, 0.75],
          ),
        ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(40,topPadding+20,40,bottomPadding+20),
          child: Column(
            children: [
              Image.asset(
                "assets/images/logo.png",
                width: 90,
                fit: BoxFit.cover,
              ),
              Text(
                "Vocabulary",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              page==0?FirstPage(
                connection: widget.connection,
                letterPress: (){
                setState(() {
                  page=1;
                });
              },
                numberPress: (){
                  setState(() {
                    page=2;
                  });
                },
              ):page==1?SecondPage(
                  connection: widget.connection,
                backPress: (){
                  setState(() {
                    page=0;
                  });
                },
              ):ThirdPage(
                  connection: widget.connection,
                backPress: (){
                  setState(() {
                    page=0;
                  });
                },
              ),
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

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key, this.letterPress, this.numberPress, required this.connection}) : super(key: key);
  final void Function()? letterPress;
  final void Function()? numberPress;
  final BluetoothConnection? connection;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyButton(
          text: "Letter from A-Z",
          onPressed: letterPress,
        ),
        SizedBox(
          height: 20,
        ),
        MyButton(text: "Numbers 0-9", onPressed: numberPress),
        SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: AutoSizeText(
            "Some basic words:",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Column(
                children: [
                  MyButton(
                    text: "Hello",
                    onPressed: () {
                      connection?.writeString("Hello");
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  MyButton(text: "Goodbye", onPressed: () {
                    connection?.writeString("Goodbye");
                  }),
                  SizedBox(
                    height: 20,
                  ),
                  MyButton(text: "Thank you", onPressed: () {
                    connection?.writeString("Thank you");
                  }),
                  SizedBox(
                    height: 20,
                  ),
                  MyButton(text: "Please", onPressed: () {
                    connection?.writeString("Please");
                  }),
                  SizedBox(
                    height: 20,
                  ),
                  MyButton(text: "Sorry", onPressed: () {
                    connection?.writeString("Sorry");
                  }),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  MyButton(text: "Yes", onPressed: () {
                    connection?.writeString("Yes");
                  }),
                  SizedBox(
                    height: 20,
                  ),
                  MyButton(text: "No", onPressed: () {
                    connection?.writeString("No");
                  }),
                  SizedBox(
                    height: 20,
                  ),
                  MyButton(text: "Help", onPressed: () {
                    connection?.writeString("Help");
                  }),
                  SizedBox(
                    height: 20,
                  ),
                  MyButton(text: "Friend", onPressed: () {
                    connection?.writeString("Friend");
                  }),
                  SizedBox(
                    height: 20,
                  ),
                  MyButton(text: "Love", onPressed: () {
                    connection?.writeString("Love");
                  }),
                  SizedBox(
                    height: 20,
                  ),
                  MyButton(text: "ILY", onPressed: () {
                    connection?.writeString("*");
                  }),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({Key? key, this.backPress, required this.connection}) : super(key: key);
  final void Function()? backPress;
  final BluetoothConnection? connection;

  @override
  Widget build(BuildContext context) {
    const List<String> alphabet = [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z'
    ];
    return Column(
      children: [
        GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10),
          itemCount: alphabet.length,
          itemBuilder: (context, index) {
            return MyButton(
              text: alphabet[index],
              onPressed: () {
                connection?.writeString(alphabet[index]);
              },
            );
          },
        ),
        SizedBox(height: 30,),
        MyButton(
          text: "Go Back",
          onPressed: backPress,
        )
      ],
    );
  }
}


class ThirdPage extends StatelessWidget {
  const ThirdPage({Key? key, this.backPress, required this.connection}) : super(key: key);
  final void Function()? backPress;
  final BluetoothConnection? connection;

  @override
  Widget build(BuildContext context) {
    const List<String> numbers = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '0'
    ];
    return Column(
      children: [
        GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10),
          itemCount: numbers.length,
          itemBuilder: (context, index) {
            return MyButton(
              text: numbers[index],
              onPressed: () {
                connection?.writeString(numbers[index]);
              },
            );
          },
        ),
        SizedBox(height: 30,),
        MyButton(
          text: "Go Back",
          onPressed: backPress,
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:intellimove/page/start.dart';
import 'package:intellimove/page/word.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_navigation_bar/responsive_navigation_bar.dart';

import 'joystick.dart';

class NavPage extends StatefulWidget {
  const NavPage({super.key,required this.flutterBlueClassicPlugin});
  final FlutterBlueClassic flutterBlueClassicPlugin;

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  int _selectedIndex = 0;
  BluetoothConnection? connection;

  bool isLoading=false;

  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    connectToDevice();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    connection?.dispose();

    super.dispose();
  }


  Future<void> connectToDevice() async {
    if (connection == null || connection?.isConnected!=true) {
      //"00:21:13:00:1F:A7" used

      try {
        connection =
        await widget.flutterBlueClassicPlugin.connect("99:4F:59:57:21:3E");
        setState(() {});
      } catch (e) {
        connection?.dispose();
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Error connecting, please ensure that the device is open'),
        //     duration: Duration(
        //         seconds: 2), // Adjust the duration as needed
        //   ),
        // );

      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if(connection?.isConnected==true) {
      return Scaffold(
        extendBody: true,
        bottomNavigationBar:ResponsiveNavigationBar(
          selectedIndex: _selectedIndex,
          inactiveIconColor: Color(0xFF003401),
          backgroundOpacity: 1,
          onTabChange: changeTab,
          backgroundColor: Colors.white,
          outerPadding: EdgeInsets.only(right: 40,left: 40,bottom: 30),
          fontSize: 20,
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          navigationBarButtons: const <NavigationBarButton>[
            NavigationBarButton(
                text: 'Voice Control',
                icon: Icons.mic,
                backgroundColor: Color(0xff223ecb)
            ),
            NavigationBarButton(
              text: 'Joystick',
              icon: Icons.gamepad,
              backgroundColor: Color(0xff223ecb),
            ),

          ],
        ),
        body: _selectedIndex==0?Start(connection: connection,):JoystickPage(connection: connection),
      );

    }else{
      double width = MediaQuery.sizeOf(context).width;
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Color(0xFF227acb),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(),
                Stack(

                  children: [
                    Center(
                      child: Image.asset(
                        "assets/images/icon.png",
                        width: width*0.6,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Center(
                      child: Opacity(
                        opacity: 0.8,
                        child: Lottie.asset(
                          "assets/lottie/search.json",
                          fit: BoxFit.contain,
                          width: width*0.7,
                          height: width*0.7,
                          controller: _controller,
                          onLoaded: (composition) {
                            _controller.duration = composition.duration * 2; // 🚀 Slow down 2x
                            _controller.repeat();
                          },
                        ),
                      ),
                    )


                  ],

                ),
                SizedBox(width: 10,),
                Text("Wheelchair not found", style: TextStyle(color: Colors.white,fontSize: 22, fontWeight: FontWeight.bold),),
                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Expanded(
                //         flex:1,
                //         child: Center(child: Padding(
                //             padding: EdgeInsets.only(top: 10),
                //             child: Icon(
                //               connection?.isConnected==true?Icons.bluetooth:Icons.bluetooth_disabled,
                //               color:  connection?.isConnected==true?Colors.green:Colors.white,size: MediaQuery.sizeOf(context).width*0.5,)))
                //     ),
                //   ],
                // ),
                SizedBox(height: 20,),
                isLoading?CircularProgressIndicator(color: Colors.white,):
                ElevatedButton(
                  child: const Text('CONNECT TO DEVICE'),
                  onPressed: () async {
                    setState(() {
                      isLoading=true;
                    });
                    await connectToDevice();
                    setState(() {
                      isLoading=false;
                    });
                  },
                ),
                SizedBox(height: 120,),

              ],
            ),
          ),
        ),
      );

    }
  }
}

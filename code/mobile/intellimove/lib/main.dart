import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intellimove/page/bluetooth_page.dart';
import 'package:intellimove/page/nav.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final flutterBlueClassicPlugin = FlutterBlueClassic();

  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  StreamSubscription? _adapterStateSubscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    BluetoothAdapterState adapterState = _adapterState;

    try {
      adapterState = await flutterBlueClassicPlugin.adapterStateNow;
      _adapterStateSubscription =
          flutterBlueClassicPlugin.adapterState.listen((current) {
            if (mounted) setState(() => _adapterState = current);
          });


    } catch (e) {
    }

    if (!mounted) return;

    setState(() {
      _adapterState = adapterState;
    });
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return MaterialApp(
      title: 'Voice Guest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF227acb)),
        useMaterial3: true,
      ),
      home: _adapterState==BluetoothAdapterState.on? NavPage(flutterBlueClassicPlugin: flutterBlueClassicPlugin):BluetoothPage(flutterBlueClassicPlugin: flutterBlueClassicPlugin),
      // home: NavPage(flutterBlueClassicPlugin: flutterBlueClassicPlugin),
    );
  }
}



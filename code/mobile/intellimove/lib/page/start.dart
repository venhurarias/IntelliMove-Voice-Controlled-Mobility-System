import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../speech_local_checker.dart';

final speechProvider = Provider<stt.SpeechToText>((ref) {
  return stt.SpeechToText();
});

// Stateful provider for managing speech state
final speechStateProvider = StateNotifierProvider<SpeechNotifier, bool>((ref) {
  final speech = ref.read(speechProvider);
  return SpeechNotifier(speech);
});

class SpeechNotifier extends StateNotifier<bool> {
  final stt.SpeechToText _speech;

  SpeechNotifier(this._speech) : super(false);

  Future<bool> initialize(Function(String)? onStatus, Function(SpeechRecognitionError)? onError) async {
    if (!_speech.isAvailable) {
      final available = await _speech.initialize(onStatus: onStatus, onError: onError);
      return available;
    }
    return true;
  }

  bool get isListening => _speech.isListening;

  void listen(Function(String) onResult) {
    if (!_speech.isListening) {
      _speech.listen(
        onResult: (val) => onResult(val.recognizedWords),
        localeId: "en_US", // match the offline language installed
      );
    }
  }

  void stop() {
    if (_speech.isListening) {
      _speech.stop();
    }
  }
}

class Start extends HookConsumerWidget {
  const Start({Key? key, required this.connection}) : super(key: key);
  final BluetoothConnection? connection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRecording = useState(false);
    final _text = useState('');
    final _opacity = useState(0.0);
    final _timer = useState<Timer?>(null);
    final speechNotifier = ref.watch(speechStateProvider.notifier);

    void _startFadeOutTimer() {
      _timer.value?.cancel();
      _timer.value = Timer(const Duration(seconds: 3), () {
        _opacity.value = 0.0;
      });
    }

    Future<void> _listen() async {
      // final checker = SpeechLocaleChecker();
      // checker.getAvailableLocales();
      final available = await speechNotifier.initialize(
        (val) {
          if (val == "done") {
            isRecording.value = false;
          }
        },
        (val) {
          isRecording.value = false;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went wrong. Please try again."), backgroundColor: Colors.red));
        },
      );

      if (!available) {
        print("Speech recognition not available.");
        return;
      }

      speechNotifier.listen((recognizedWords) {
        print("RECOGNIZE :: $recognizedWords");
        recognizedWords=recognizedWords.toLowerCase();
        if (recognizedWords == "forward") {
          connection?.writeString("1");
          isRecording.value = false;
          _text.value = "Forward";
          _opacity.value = 1.0;
          _startFadeOutTimer();
        } else if (recognizedWords == "backward") {
          connection?.writeString("2");
          isRecording.value = false;
          _text.value = "Backward";
          _opacity.value = 1.0;
          _startFadeOutTimer();
        } else if (recognizedWords == "left") {
          connection?.writeString("3");
          isRecording.value = false;
          _text.value = "Left";
          _opacity.value = 1.0;
          _startFadeOutTimer();
        } else if (recognizedWords == "right") {
          connection?.writeString("4");
          isRecording.value = false;
          _text.value = "Right";
          _opacity.value = 1.0;
          _startFadeOutTimer();
        }else if (recognizedWords == "stop") {
          connection?.writeString("0");
          isRecording.value = false;
          _text.value = "Stop";
          _opacity.value = 1.0;
          _startFadeOutTimer();
        }
      });
    }

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
              const SizedBox(height: 10),
              Expanded(
                flex: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
Stack(children: [
  Align(
    alignment: Alignment.topRight,
    child: Material(
      elevation: 10,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: Ink(
        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: IconButton(
            icon: Icon(Icons.stop, color: Colors.white),
            iconSize: MediaQuery.sizeOf(context).width * 0.08,
            onPressed: () {
              connection?.writeString("0");
              isRecording.value = false;
              _text.value = "Stop";
              _opacity.value = 1.0;
              _startFadeOutTimer();
            },
          ),
        ),
      ),
    ),
  ),
  Center(
    child: Padding(
      padding: EdgeInsets.only(top: 40),
      child: RippleAnimation(
        color: Colors.white,
        delay: const Duration(milliseconds: 600),
        repeat: true,
        minRadius: MediaQuery.sizeOf(context).width * 0.25,
        ripplesCount: 3,
        duration: const Duration(milliseconds: 6 * 300),
        child: Material(
          elevation: 20,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: Ink(
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: IconButton(
                icon: Icon(isRecording.value ? Icons.mic : Icons.mic_off, color: const Color(0xFF003401)),
                iconSize: MediaQuery.sizeOf(context).width * 0.45,
                onPressed: () {
                  isRecording.value = !isRecording.value;
                  if (isRecording.value) {
                    _listen();
                  } else {
                    speechNotifier.stop();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    ),
  )
],),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            isRecording.value ? "Tap to Stop Recording" : "Tap to Start Recording",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 24, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 10,
                child: AnimatedOpacity(
                  opacity: _opacity.value,
                  duration: const Duration(seconds: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        _text.value == "Forward"
                            ? Icons.arrow_upward
                            : _text.value == "Backward"
                            ? Icons.arrow_downward
                            : _text.value == "Right"
                            ? Icons.arrow_forward_outlined
                            : _text.value == "Left"
                            ? Icons.arrow_back
                            : Icons.stop,
                        size: 42,
                        color: Colors.white,
                      ),
                      Text(_text.value.toUpperCase(), style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';


final speechToTextProvider =
StateNotifierProvider<SpeechToTextNotifier, bool>((ref) {
  return SpeechToTextNotifier();
});


class SpeechToTextNotifier extends StateNotifier<bool> {
  final SpeechToText _speech = SpeechToText();
  String _text = '';

  SpeechToTextNotifier() : super(false);

  bool get isListening => state;
  String get recognizedText => _text;

  Future<bool> initialize() async {
    if (!_speech.isAvailable) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done') {
            stop();
          }
        },
        onError: (error) {
          stop();
          print('SpeechToText Error: $error');
        },
      );
      return available;
    }
    return true;
  }

  void listen(Function(String) onResult) {
    if (!_speech.isListening) {
      _speech.listen(
        onResult: (val) {
          _text = val.recognizedWords;
          onResult(_text);
        },
      );
      state = true;
    }
  }

  void stop() {
    if (_speech.isListening) {
      _speech.stop();
    }
    state = false;
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}

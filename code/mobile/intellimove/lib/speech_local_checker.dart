import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechLocaleChecker {
  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<void> getAvailableLocales() async {
    bool available = await _speech.initialize();
    if (!available) {
      print('Speech recognition not available');
      return;
    }

    List<stt.LocaleName> locales = await _speech.locales();

    print("Available Locales:");
    for (var locale in locales) {
      print('${locale.name} → ${locale.localeId}');
    }
  }
}

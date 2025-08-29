
//import 'package:speech_to_text/speech_to_text.dart' as stt;

typedef StatusCallback = void Function(String status);
typedef ErrorCallback = void Function(String error);
typedef ResultCallback = void Function(String text);

/*
class SpeechManager {
  // Singleton Instance
  static final SpeechManager _instance = SpeechManager._internal();
  factory SpeechManager() => _instance;
  SpeechManager._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  stt.SpeechToText get speech => _speech;

  // Clean old listeners
  Future<bool> initialize({
    required StatusCallback onStatus,
    required ErrorCallback onError,
    required ResultCallback onResult,
  }) async {
    bool available = await _speech.initialize(
      onStatus: onStatus,
      onError: (error) {
        onError(error.errorMsg);
      },
    );
    return available;
  }

  void startListening({required ResultCallback onResult}) {
    _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
    );
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
  }
  void forceStopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    if (_speech.isAvailable) {
      await _speech.cancel();
    }
  }


  bool get isListening => _speech.isListening;


}


*/


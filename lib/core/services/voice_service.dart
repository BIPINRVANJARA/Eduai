import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum VoiceState {
  idle,
  listening,
  processing,
  speaking,
  error,
}

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isSpeechInitialized = false;
  bool _isTtsInitialized = false;

  VoiceState _state = VoiceState.idle;
  VoiceState get state => _state;

  final StreamController<VoiceState> _stateController = StreamController<VoiceState>.broadcast();
  Stream<VoiceState> get stateStream => _stateController.stream;

  final StreamController<double> _soundLevelController = StreamController<double>.broadcast();
  Stream<double> get soundLevelStream => _soundLevelController.stream;

  final StreamController<String> _wordsController = StreamController<String>.broadcast();
  Stream<String> get wordsStream => _wordsController.stream;

  Future<bool> init() async {
    try {
      // 1. Initialize Speech To Text
      if (!_isSpeechInitialized) {
        _isSpeechInitialized = await _speech.initialize(
          onError: (val) {
            if (kDebugMode) print('STT Error: $val');
            _setState(VoiceState.idle);
          },
          onStatus: (val) {
            if (kDebugMode) print('STT Status: $val');
            if (val == 'done' || val == 'notListening') {
              if (_state == VoiceState.listening) {
                _setState(VoiceState.processing);
              }
            }
          },
        );
      }

      // 2. Initialize Text To Speech
      if (!_isTtsInitialized) {
        await _tts.setSpeechRate(0.52);
        await _tts.setVolume(1.0);
        await _tts.setPitch(1.0);

        _tts.setStartHandler(() {
          _setState(VoiceState.speaking);
        });

        _tts.setCompletionHandler(() {
          _setState(VoiceState.idle);
        });

        _tts.setErrorHandler((msg) {
          if (kDebugMode) print('TTS Error: $msg');
          _setState(VoiceState.idle);
        });

        _isTtsInitialized = true;
      }

      return _isSpeechInitialized;
    } catch (e) {
      if (kDebugMode) print('VoiceService init error: $e');
      return false;
    }
  }

  void _setState(VoiceState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  /// Start listening to user voice with multilingual auto-detection
  Future<void> startListening({
    required Function(String recognizedWords, bool isFinal) onResult,
  }) async {
    await stopSpeaking();

    if (!_isSpeechInitialized) {
      final success = await init();
      if (!success) {
        _setState(VoiceState.error);
        return;
      }
    }

    _setState(VoiceState.listening);

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        _wordsController.add(result.recognizedWords);
        onResult(result.recognizedWords, result.finalResult);
      },
      onSoundLevelChange: (level) {
        _soundLevelController.add(level);
      },
      listenFor: const Duration(seconds: 25),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_IN', // Defaults to Indian locale, supporting phonetic recognition
      cancelOnError: true,
      partialResults: true,
    );
  }

  /// Stop listening explicitly
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    _setState(VoiceState.idle);
  }

  /// Speak text with automatic language detection (en-IN, gu-IN, hi-IN)
  Future<void> speak(String text) async {
    await stopListening();

    if (text.trim().isEmpty) return;

    if (!_isTtsInitialized) {
      await init();
    }

    // Clean markdown and formatting tags for voice output
    String speechText = text
        .replaceAll(RegExp(r'\*\*'), '')
        .replaceAll(RegExp(r'•'), '')
        .replaceAll(RegExp(r'#'), '')
        .replaceAll(RegExp(r'\[ATTACH_DOC:.*?\]'), '')
        .replaceAll(RegExp(r'`.*?`'), '')
        .trim();

    // Detect language script
    final bool isGujarati = RegExp(r'[\u0A80-\u0AFF]').hasMatch(speechText);
    final bool isHindi = RegExp(r'[\u0900-\u097F]').hasMatch(speechText);

    try {
      if (isGujarati) {
        await _tts.setLanguage('gu-IN');
      } else if (isHindi) {
        await _tts.setLanguage('hi-IN');
      } else {
        await _tts.setLanguage('en-IN');
      }
    } catch (_) {
      await _tts.setLanguage('en-US');
    }

    _setState(VoiceState.speaking);
    await _tts.speak(speechText);
  }

  /// Stop speech playback immediately
  Future<void> stopSpeaking() async {
    if (_isTtsInitialized) {
      await _tts.stop();
    }
    if (_state == VoiceState.speaking) {
      _setState(VoiceState.idle);
    }
  }

  /// Stop everything
  Future<void> stopAll() async {
    await stopListening();
    await stopSpeaking();
    _setState(VoiceState.idle);
  }

  void dispose() {
    _speech.cancel();
    _tts.stop();
    _stateController.close();
    _soundLevelController.close();
    _wordsController.close();
  }
}

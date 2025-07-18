import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class SpeechToTextHelper {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  String _lastRecognizedWords = '';
  String? _audioFilePath;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Completer<String>? _completer;
  bool _hasReceivedResults = false;
  List<LocaleName>? _availableLocales;

  Future<void> initSpeech() async {
    try {
      _isInitialized = await _speech.initialize(
        onStatus: _onStatus,
        onError: _onError,
      );

      if (_isInitialized) {
        // Get available locales for speech recognition
        _availableLocales = await _speech.locales();
        debugPrint('[STT] Speech-to-text initialized successfully with ${_availableLocales?.length} locales.');
        if (_availableLocales != null) {
          for (var locale in _availableLocales!) {
            debugPrint('[STT] Available locale: ${locale.localeId} - ${locale.name}');
          }
        }
      } else {
        debugPrint('[STT] Failed to initialize speech-to-text.');
      }
    } catch (e) {
      debugPrint('[STT] Initialization error: $e');
    }
  }

  // Get list of available locales for UI
  List<LocaleName> getAvailableLocales() {
    return _availableLocales ?? [];
  }

  // Check if a specific locale is available
  bool isLocaleAvailable(String localeId) {
    return _availableLocales?.any((locale) => locale.localeId == localeId) ?? false;
  }

  // Find best matching locale from available locales
  String findBestMatchingLocale(String preferredLocale) {
    // Default to English if preferred locale not available
    if (_availableLocales == null || _availableLocales!.isEmpty) {
      return 'en_US';
    }
    
    // Try to find exact match
    bool hasExactMatch = _availableLocales!.any((locale) => 
      locale.localeId == preferredLocale);
    
    if (hasExactMatch) {
      return preferredLocale;
    }
    
    // Try to find match with same language code (first part of locale)
    String languageCode = preferredLocale.split('_')[0];
    var sameLanguageLocale = _availableLocales!.firstWhere(
      (locale) => locale.localeId.startsWith('$languageCode\_'), 
      orElse: () => _availableLocales!.firstWhere(
        (locale) => locale.localeId == 'en_US',
        orElse: () => _availableLocales!.first
      )
    );
    
    return sameLanguageLocale.localeId;
  }

  Future<String> listenOnce({
    String localeId = 'en_US',
    Duration timeout = const Duration(seconds: 40),
  }) async {
    if (!_isInitialized) {
      await initSpeech();
    }

    if (!_speech.isAvailable) {
      final error = '[STT] Speech recognition not available.';
      debugPrint(error);
      throw Exception(error);
    }

    _lastRecognizedWords = '';
    _hasReceivedResults = false;
    _completer = Completer<String>();

    // Find best matching locale from available ones
    String bestLocale = findBestMatchingLocale(localeId);
    debugPrint('[STT] Using locale: $bestLocale for requested: $localeId');

    try {
      debugPrint('[STT] Listening started with locale: $bestLocale');
      await _speech.listen(
        onResult: (result) {
          debugPrint('[STT] Result received: ${result.recognizedWords}');

          if (result.recognizedWords.isNotEmpty) {
            _hasReceivedResults = true;
            _lastRecognizedWords = result.recognizedWords;
          }

          // We don't complete the future here automatically anymore
          // This prevents automatic completion on pauses
        },
        localeId: bestLocale,
        listenMode: ListenMode.dictation,
        pauseFor: const Duration(seconds: 5), // Extended pause duration
      );

      // Create a timer for the timeout
      Timer? timeoutTimer;
      timeoutTimer = Timer(timeout, () {
        if (!_completer!.isCompleted) {
          debugPrint('[STT] Timeout reached, stopping listening...');
          stopListening();
        }
      });

      final result = await _completer!.future;
      timeoutTimer.cancel();
      return result;
    } catch (e) {
      debugPrint('[STT] Listen error: $e');
      stopListening();
      rethrow;
    }
  }

  void stopListening() {
    if (_speech.isListening) {
      _speech.stop();
      debugPrint('[STT] Listening stopped manually.');
    }

    // When stopped (manually or automatically), complete with the current transcription
    if (_completer != null && !_completer!.isCompleted) {
      if (_hasReceivedResults && _lastRecognizedWords.isNotEmpty) {
        debugPrint(
          '[STT] Completing with current transcription: $_lastRecognizedWords',
        );
        _completer!.complete(_lastRecognizedWords);
      } else {
        debugPrint('[STT] No results received, completing with empty string');
        _completer!.complete('');
      }
    }
  }

  void _onStatus(String status) {
    debugPrint('[STT] Status update: $status');

    // When we receive "done" status but the completer is still pending,
    // complete it with the current results
    if (status == "done" && _completer != null && !_completer!.isCompleted) {
      if (_hasReceivedResults && _lastRecognizedWords.isNotEmpty) {
        debugPrint(
          '[STT] Status done - completing with: $_lastRecognizedWords',
        );
        _completer!.complete(_lastRecognizedWords);
      }
    }
  }

  void _onError(SpeechRecognitionError error) {
    debugPrint(
      '[STT] Speech error: ${error.errorMsg} (permanent: ${error.permanent})',
    );

    if (_completer != null && !_completer!.isCompleted) {
      // Only complete with empty string if we haven't received any results
      if (!_hasReceivedResults) {
        _completer!.complete('');
      } else {
        // Otherwise, use the last recognized words
        _completer!.complete(_lastRecognizedWords);
      }
    }
  }

  // Record audio to a file for playback
  Future<String?> saveAudioToFile(String text) async {
    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${directory.path}/recording_$timestamp.txt';

      final file = File(path);
      await file.writeAsString(text);

      _audioFilePath = path;
      debugPrint('[STT] Saved audio reference to: $path');
      return path;
    } catch (e) {
      debugPrint('[STT] Error saving audio reference: $e');
      return null;
    }
  }

  // Simulate audio playback
  Future<void> playRecordedAudio() async {
    try {
      if (_audioFilePath != null && File(_audioFilePath!).existsSync()) {
        debugPrint('[STT] Simulating playback from: $_audioFilePath');

        // Read the content to simulate real playback
        final file = File(_audioFilePath!);
        final content = await file.readAsString();
        debugPrint('[STT] Audio content: $content');

        // Simulate audio duration based on content length
        final playDuration = Duration(milliseconds: content.length * 50);
        debugPrint('[STT] Playing for: ${playDuration.inMilliseconds}ms');

        // Return after the simulated duration
        return Future.delayed(playDuration);
      } else {
        debugPrint('[STT] Audio file not found: $_audioFilePath');
      }
    } catch (e) {
      debugPrint('[STT] Error playing audio: $e');
    }
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  void dispose() {
    _audioPlayer.dispose();
  }

  String getLastRecognizedWords() {
    return _lastRecognizedWords;
  }

  bool get isListening => _speech.isListening;
  String? get audioFilePath => _audioFilePath;
}
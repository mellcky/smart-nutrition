import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

/// A service class that handles speech-to-text functionality
/// with support for multiple languages and error handling.
class VoiceService {
  // Singleton pattern
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  // Speech to text instance
  final stt.SpeechToText _speech = stt.SpeechToText();

  // Status variables
  bool _isInitialized = false;
  bool _isListening = false;
  double _soundLevel = 0.0;
  String _lastStatus = '';
  String _lastError = '';
  String _recognizedText = '';
  String _currentLocaleId = '';
  List<LocaleName> _locales = [];

  // Multi-language support
  bool _isMultiLanguageEnabled = true;
  List<String> _preferredLanguages = ['en_US', 'sw_TZ', 'sw_KE']; // English and Swahili
  String _detectedLanguage = '';

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  double get soundLevel => _soundLevel;
  String get lastStatus => _lastStatus;
  String get lastError => _lastError;
  String get recognizedText => _recognizedText;
  String get currentLocaleId => _currentLocaleId;
  List<LocaleName> get locales => _locales;
  bool get isMultiLanguageEnabled => _isMultiLanguageEnabled;
  String get detectedLanguage => _detectedLanguage;

  /// Initialize the speech recognition service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onStatus: _onStatusChange,
        onError: _onErrorListener,
        debugLogging: false,
      );

      if (_isInitialized) {
        // Convert speech_to_text LocaleName objects to our custom LocaleName class
        final speechLocales = await _speech.locales();
        _locales = speechLocales.map((locale) => 
          LocaleName(locale.name, locale.localeId)
        ).toList();

        // Log available locales for debugging
        debugPrint('Available locales: ${_locales.map((l) => "${l.name} (${l.localeId})").join(", ")}');

        // Find the best locale for multi-language support
        _currentLocaleId = await _findBestMultiLanguageLocale();

        debugPrint('Selected locale for multi-language: $_currentLocaleId');
      }

      return _isInitialized;
    } catch (e) {
      _lastError = 'Failed to initialize speech recognition: $e';
      return false;
    }
  }

  /// Find the best locale for multi-language support
  Future<String> _findBestMultiLanguageLocale() async {
    // Try to find a locale that might support both English and Swahili
    // This is a heuristic approach as speech recognition engines typically use one language at a time

    // First check if any of our preferred languages are available
    for (var preferredLocale in _preferredLanguages) {
      if (isLanguageAvailable(preferredLocale)) {
        return preferredLocale;
      }
    }

    // If no preferred locale is available, try to find a general English locale
    // English often has better recognition for mixed language content
    for (var locale in _locales) {
      if (locale.localeId.startsWith('en')) {
        return locale.localeId;
      }
    }

    // If no English locale is available, use the system locale or fallback to English
    var systemLocale = await _speech.systemLocale();
    return systemLocale?.localeId ?? 'en_US';
  }

  /// Start listening for speech
  Future<bool> startListening({
    String? localeId,
    Function(String text)? onResult,
    Function(double level)? onSoundLevel,
    int maxDuration = 30000, // 30 seconds
  }) async {
    if (!_isInitialized) {
      bool initialized = await initialize();
      if (!initialized) return false;
    }

    _recognizedText = '';

    // If multi-language is enabled, use the best locale for multi-language support
    String selectedLocale = localeId ?? _currentLocaleId;

    debugPrint('Starting speech recognition with locale: $selectedLocale');

    try {
      _isListening = await _speech.listen(
        onResult: (result) => _onSpeechResult(result, onResult),
        listenFor: Duration(milliseconds: maxDuration),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: selectedLocale,
        onSoundLevelChange: (level) {
          _soundLevel = level;
          onSoundLevel?.call(level);
        },
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );

      return _isListening;
    } catch (e) {
      _lastError = 'Failed to start listening: $e';
      _isListening = false;
      return false;
    }
  }

  /// Stop listening for speech
  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stop();
  }

  /// Cancel listening for speech
  Future<void> cancelListening() async {
    _isListening = false;
    await _speech.cancel();
    _recognizedText = '';
  }

  /// Set the current locale for speech recognition
  void setLocale(String localeId) {
    _currentLocaleId = localeId;
  }

  /// Handle speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result, Function(String)? onResult) {
    _recognizedText = result.recognizedWords;

    // Try to detect the language from the recognized text
    if (_recognizedText.isNotEmpty) {
      _detectLanguageFromText(_recognizedText);
    }

    // Call the callback with the recognized text
    if (result.finalResult) {
      onResult?.call(_recognizedText);
    }
  }

  /// Detect language from text
  void _detectLanguageFromText(String text) {
    // This is a simple heuristic approach to detect language
    // For a production app, consider using a proper language detection library

    // Check for Swahili-specific words or patterns
    final swahiliWords = [
      'habari', 'jambo', 'asante', 'karibu', 'nzuri', 'sana', 'kwaheri', 'pole',
      'chakula', 'maji', 'ndio', 'hapana', 'tafadhali', 'kula', 'kunywa', 'na',
      'mimi', 'wewe', 'yeye', 'sisi', 'ninyi', 'wao', 'ni', 'si', 'kwa'
    ];

    // Count Swahili words in the text
    int swahiliWordCount = 0;
    final words = text.toLowerCase().split(' ');

    for (var word in words) {
      if (swahiliWords.contains(word)) {
        swahiliWordCount++;
      }
    }

    // If there are Swahili words, consider it mixed or Swahili
    if (swahiliWordCount > 0) {
      if (swahiliWordCount / words.length > 0.5) {
        _detectedLanguage = 'Swahili';
      } else {
        _detectedLanguage = 'Mixed (English/Swahili)';
      }
    } else {
      _detectedLanguage = 'English';
    }

    debugPrint('Detected language: $_detectedLanguage');
  }

  /// Handle status changes
  void _onStatusChange(String status) {
    _lastStatus = status;
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
    }
  }

  /// Handle errors
  void _onErrorListener(SpeechRecognitionError error) {
    _lastError = '${error.errorMsg} (${error.permanent})';
    _isListening = false;
  }

  /// Get a list of available languages for speech recognition
  Future<List<LocaleName>> getAvailableLanguages() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _locales;
  }

  /// Check if a specific language is available
  bool isLanguageAvailable(String localeId) {
    return _locales.any((locale) => locale.localeId == localeId);
  }

  /// Find the best matching language based on a language code
  String findBestLanguageMatch(String languageCode) {
    // First try to find an exact match
    for (var locale in _locales) {
      if (locale.localeId.startsWith(languageCode)) {
        return locale.localeId;
      }
    }

    // If no match found, return the default locale
    return _currentLocaleId;
  }

  /// Enable or disable multi-language support
  void setMultiLanguageEnabled(bool enabled) {
    _isMultiLanguageEnabled = enabled;
  }

  /// Set preferred languages for multi-language support
  void setPreferredLanguages(List<String> languages) {
    _preferredLanguages = languages;
  }
}

/// A class to represent a locale name
class LocaleName {
  final String name;
  final String localeId;

  LocaleName(this.name, this.localeId);
}

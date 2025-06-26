import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:diet_app/services/gemini_service.dart';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import 'package:diet_app/providers/fooditem_provider.dart';
import 'package:diet_app/models/food_item.dart';
import '/db/user_database_helper.dart';
import 'package:diet_app/screens/tracker_screen.dart';
import 'package:flutter/services.dart'; // Added for HapticFeedback

class FoodRecognitionScreen2 extends StatefulWidget {
  final String mealType;
  const FoodRecognitionScreen2({super.key, required this.mealType});
  @override
  State<FoodRecognitionScreen2> createState() => _FoodRecognitionScreen2State();
}

class _FoodRecognitionScreen2State extends State<FoodRecognitionScreen2> {
  File? _image;
  bool _busy = false;
  bool _nutritionBusy = false;
  String? _errorMessage;

  // Speech recognition
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _speechText = '';
  double _soundLevel = 0.0;
  String _lastSpeechStatus = '';
  bool _speechAvailable = false;

  List<String> _imageDetectedFoodItems = [];
  List<Map<String, dynamic>> _imageDetectedFoodItemsWithNutrition = [];

  List<String> _textDetectedFoodItems = [];
  List<Map<String, dynamic>> _textDetectedFoodItemsWithNutrition = [];

  final TextEditingController _foodDescriptionController =
      TextEditingController();
  bool _isTextInputMode = false;

  final Map<String, List<String>> _imageAnalysisCache = {};
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _preWarmImagePicker();
    _initSpeech();
  }

  Future<void> _preWarmImagePicker() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (_) {}
  }

  // Initialize speech recognition
  void _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          setState(() {
            _lastSpeechStatus = status;
            if (status == 'done') {
              _isListening = false;
            }
          });
        },
        onError: (error) {
          setState(() {
            _lastSpeechStatus = 'Error: ${error.errorMsg}';
            _isListening = false;
          });
        },
        debugLogging: false,
      );

      if (!available) {
        setState(() => _errorMessage = 'Speech recognition not available');
      }

      setState(() => _speechAvailable = available);
    } catch (e) {
      setState(() => _errorMessage = 'Speech init failed: ${e.toString()}');
    }
  }

  // Start voice recording
  void _startRecording() {
    if (!_speechAvailable) {
      setState(() => _errorMessage = 'Speech not initialized');
      return;
    }

    setState(() {
      _isListening = true;
      _speechText = '';
      _foodDescriptionController.text = '';
      _soundLevel = 0.0;
      _lastSpeechStatus = 'listening...';
    });

    // Provide haptic feedback
    HapticFeedback.mediumImpact();

    _speech.listen(
      onResult: (result) {
        setState(() {
          _speechText = result.recognizedWords;
          _foodDescriptionController.text = _speechText;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
      onSoundLevelChange: (level) {
        setState(() => _soundLevel = level);
      },
      cancelOnError: true,
      partialResults: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  // Stop voice recording
  void _stopRecording() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _lastSpeechStatus = 'processing...';

      // Add punctuation if missing
      _speechText = _addPunctuation(_speechText);
      _foodDescriptionController.text = _speechText;
    });

    // Provide haptic feedback
    HapticFeedback.lightImpact();
  }

  // Add punctuation to speech text
  String _addPunctuation(String text) {
    if (text.isEmpty) return text;

    // Trim and add period if missing
    text = text.trim();
    final lastChar = text[text.length - 1];
    if (lastChar != '.' && lastChar != '!' && lastChar != '?') {
      text += '.';
    }

    // Capitalize first letter
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  void dispose() {
    _foodDescriptionController.dispose();
    _speech.stop();
    super.dispose();
  }

  // Clear text input fields
  void _clearTextInput() {
    setState(() {
      _foodDescriptionController.clear();
      _speechText = '';
      _textDetectedFoodItems = [];
      _textDetectedFoodItemsWithNutrition = [];
    });
  }

  Future<void> _analyzeTextInput(String text) async {
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a food description')),
      );
      return;
    }

    // Clear any previous text results
    _clearTextInput();

    setState(() {
      _busy = true;
      _nutritionBusy = true;
      _errorMessage = null;
      _image = null;
      _imageDetectedFoodItems = [];
      _imageDetectedFoodItemsWithNutrition = [];
    });

    try {
      final foodItemsWithNutrition =
          await GeminiService.extractFoodItemsFromText(text);

      if (foodItemsWithNutrition.isEmpty) {
        throw Exception('No food items detected in the description');
      }

      final List<String> foodNames =
          foodItemsWithNutrition
              .map((item) => item['name'] as String)
              .where((name) => name.isNotEmpty)
              .toList();

      if (mounted) {
        setState(() {
          _textDetectedFoodItems = foodNames;
          _textDetectedFoodItemsWithNutrition = foodItemsWithNutrition;
          _busy = false;
          _nutritionBusy = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _nutritionBusy = false;
          _errorMessage = 'Error analyzing text: ${e.toString()}';
        });

        String errorMsg = e.toString();
        if (errorMsg.length > 100) {
          errorMsg = '${errorMsg.substring(0, 100)}...';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error analyzing text: $errorMsg',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        debugPrint('Text analysis error: $e');
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1200,
        maxHeight: 1200,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _busy = true;
          _nutritionBusy = true;
          _errorMessage = null;
          _textDetectedFoodItems = [];
          _textDetectedFoodItemsWithNutrition = [];
          _imageDetectedFoodItems = [];
          _imageDetectedFoodItemsWithNutrition = [];
        });
        await _analyzeImage(_image!);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error accessing camera: ${e.toString()}';
        _busy = false;
        _nutritionBusy = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error accessing camera: $e')));
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _busy = true;
          _nutritionBusy = true;
          _errorMessage = null;
          _textDetectedFoodItems = [];
          _textDetectedFoodItemsWithNutrition = [];
          _imageDetectedFoodItems = [];
          _imageDetectedFoodItemsWithNutrition = [];
        });
        await _analyzeImage(_image!);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error accessing gallery: ${e.toString()}';
        _busy = false;
        _nutritionBusy = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error accessing gallery: $e')));
    }
  }

  Future<void> _analyzeImage(File image) async {
    if (!mounted) return;

    try {
      if (!await image.exists()) {
        throw Exception('Image file does not exist');
      }

      final fileSize = await image.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Image file is too large (max 10MB)');
      }

      final Uint8List imageBytes = await image.readAsBytes();
      String mimeType = 'image/jpeg';
      final String extension = image.path.split('.').last.toLowerCase();
      switch (extension) {
        case 'png':
          mimeType = 'image/png';
          break;
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        default:
          mimeType = 'image/jpeg';
      }

      final String imagePath = image.path;
      if (_imageAnalysisCache.containsKey(imagePath)) {
        setState(() {
          _imageDetectedFoodItems = _imageAnalysisCache[imagePath]!;
          _busy = false;
        });
        await _loadNutritionData(imageBytes, mimeType);
        return;
      }

      final prompt =
          '''First, determine if this image contains edible food items.

If the image does NOT contain any food (e.g., it shows objects like trees, shoes, furniture, people, landscapes, or other non-food items), respond with exactly "NO_FOOD_DETECTED" and nothing else.

Consider the following as food:
- Any prepared meals or dishes
- Raw ingredients (fruits, vegetables, meats, grains)
- Packaged food products
- Beverages (drinks, smoothies)
- Snacks and desserts

If the image DOES contain food, identify only the food items visible. List each item separately (like fish, stew, rice, etc.). Be specific about varieties when possible (e.g., "grilled chicken" instead of just "chicken"). Return only a simple list of food items without any additional analysis or description.''';

      List<String> foodItems;
      try {
        foodItems = await compute((Map<String, dynamic> params) async {
          try {
            final Uint8List bytes = params['imageBytes'] as Uint8List;
            final String mime = params['mimeType'] as String;
            final String customPrompt = params['prompt'] as String;

            final String analysisResult =
                await GeminiService.analyzeImageFromBytesAndMimeType(
                  bytes,
                  mime,
                  customPrompt: customPrompt,
                );

            return _parseFoodItemsFromResponse(analysisResult);
          } catch (e, stackTrace) {
            print('Error in isolate: ${e.toString()}\n$stackTrace');
            return ["ERROR: ${e.toString()}"];
          }
        }, {'imageBytes': imageBytes, 'mimeType': mimeType, 'prompt': prompt});

        if (foodItems.isNotEmpty && foodItems[0].startsWith("ERROR:")) {
          throw Exception(foodItems[0].substring(6));
        }
      } catch (e) {
        throw Exception('Failed to analyze image: ${e.toString()}');
      }

      _imageAnalysisCache[imagePath] = foodItems;

      if (mounted) {
        setState(() {
          _imageDetectedFoodItems = foodItems;
          _busy = false;
        });

        await _loadNutritionData(imageBytes, mimeType);

        if (foodItems.length == 1 && foodItems[0] == 'NO_FOOD_DETECTED') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No food detected in this image. Please try with a food photo.',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange[700],
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _nutritionBusy = false;
          _errorMessage = 'Error analyzing image: ${e.toString()}';
        });

        String errorMsg = e.toString();
        if (errorMsg.length > 100) {
          errorMsg = '${errorMsg.substring(0, 100)}...';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error analyzing image: $errorMsg',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        debugPrint('Image analysis error: $e');
      }
    }
  }

  Future<void> _loadNutritionData(Uint8List imageBytes, String mimeType) async {
    if (!mounted) return;

    setState(() {
      _nutritionBusy = true;
    });

    try {
      final nutritionData = await compute((Map<String, dynamic> params) async {
        final Uint8List bytes = params['imageBytes'] as Uint8List;
        final String mime = params['mimeType'] as String;
        return await GeminiService.extractFoodItemsFromBytesAndMimeType(
          bytes,
          mime,
        );
      }, {'imageBytes': imageBytes, 'mimeType': mimeType});

      if (mounted) {
        setState(() {
          _imageDetectedFoodItemsWithNutrition = nutritionData;
          _nutritionBusy = false;

          if (nutritionData.isNotEmpty &&
              !(_imageDetectedFoodItems.length == 1 &&
                  _imageDetectedFoodItems[0] == 'NO_FOOD_DETECTED')) {
            _imageDetectedFoodItems =
                nutritionData
                    .map((item) => item['name']?.toString() ?? '')
                    .where((name) => name.isNotEmpty)
                    .toList();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _nutritionBusy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nutrition analysis failed: ${e.toString()}')),
        );
        debugPrint('Nutrition data loading error: $e');
      }
    }
  }

  static List<String> _parseFoodItemsFromResponse(String response) {
    if (response.trim().toUpperCase().contains('NO_FOOD_DETECTED')) {
      return ['NO_FOOD_DETECTED'];
    }

    List<String> items = [];
    String cleanedResponse = response
        .replaceAll('*', '')
        .replaceAll('#', '')
        .replaceAll('-', '');

    if (cleanedResponse.contains('\n')) {
      items =
          cleanedResponse
              .split('\n')
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList();
    } else if (cleanedResponse.contains(',')) {
      items =
          cleanedResponse
              .split(',')
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList();
    } else if (cleanedResponse.contains('•')) {
      items =
          cleanedResponse
              .split('•')
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList();
    } else {
      items = [cleanedResponse.trim()];
    }

    items =
        items
            .map((item) {
              item = item.replaceAll(RegExp(r'^\d+\.\s*'), '');
              item = item.replaceAll(RegExp(r'[.:]$'), '');
              return item.trim();
            })
            .where((item) => item.isNotEmpty)
            .toList();

    return items;
  }

  // Log food item and navigate to tracker
  void _logFoodItem(
    String foodName,
    Map<String, dynamic>? nutritionInfo,
  ) async {
    if (nutritionInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nutrition data not available for $foodName')),
      );
      return;
    }

    final foodItem = FoodItem(
      foodItem: foodName,
      calories: nutritionInfo['calories']?.toDouble() ?? 0.0,
      protein: nutritionInfo['protein']?.toDouble() ?? 0.0,
      carbs: nutritionInfo['carbs']?.toDouble() ?? 0.0,
      fats: nutritionInfo['fats']?.toDouble() ?? 0.0,
      saturatedFat: nutritionInfo['saturatedFat']?.toDouble() ?? 0.0,
      chorestrol: nutritionInfo['cholesterol']?.toDouble() ?? 0.0,
      sugar: nutritionInfo['sugar']?.toDouble() ?? 0.0,
      fiber: nutritionInfo['fiber']?.toDouble() ?? 0.0,
      sodium: nutritionInfo['sodium']?.toDouble() ?? 0.0,
      vitaminA: nutritionInfo['vitaminA']?.toDouble() ?? 0.0,
      vitaminD: nutritionInfo['vitaminD']?.toDouble() ?? 0.0,
      vitaminC: nutritionInfo['vitaminC']?.toDouble() ?? 0.0,
      vitaminE: nutritionInfo['vitaminE']?.toDouble() ?? 0.0,
      vitaminB6: nutritionInfo['vitaminB6']?.toDouble() ?? 0.0,
      vitaminB12: nutritionInfo['vitaminB12']?.toDouble() ?? 0.0,
      ca: nutritionInfo['ca']?.toDouble() ?? 0.0,
      mg: nutritionInfo['mg']?.toDouble() ?? 0.0,
      k: nutritionInfo['k']?.toDouble() ?? 0.0,
      fe: nutritionInfo['fe']?.toDouble() ?? 0.0,
      zn: nutritionInfo['zn']?.toDouble() ?? 0.0,
      mealType: widget.mealType,
      timestamp: DateTime.now(),
      imagePath: _image?.path ?? '',
    );

    try {
      // Save to provider
      Provider.of<FoodItemProvider>(
        context,
        listen: false,
      ).logFoodItem(foodItem);

      // Save to database
      await UserDatabaseHelper().insertFoodItem(foodItem);

      // Check if widget is still mounted before showing SnackBar
      if (!mounted) return;

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Logged $foodName successfully!',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

      // Wait for the SnackBar to be visible before navigating
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if widget is still mounted before navigating
      if (!mounted) return;
    } catch (error) {
      // Handle any errors during logging
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to log $foodName: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> currentDetectedFoodItems =
        _isTextInputMode ? _textDetectedFoodItems : _imageDetectedFoodItems;
    final List<Map<String, dynamic>> currentDetectedFoodItemsWithNutrition =
        _isTextInputMode
            ? _textDetectedFoodItemsWithNutrition
            : _imageDetectedFoodItemsWithNutrition;

    return Scaffold(
      appBar: AppBar(title: const Text('Food Recognition'), centerTitle: true),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input mode toggle
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _busy
                                ? null
                                : () {
                                  setState(() {
                                    _isTextInputMode = false;
                                    _errorMessage = null;
                                    _clearTextInput();
                                    _imageDetectedFoodItems = [];
                                    _imageDetectedFoodItemsWithNutrition = [];
                                  });
                                },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              !_isTextInputMode
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[300],
                          foregroundColor:
                              !_isTextInputMode
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _busy
                                ? null
                                : () {
                                  setState(() {
                                    _isTextInputMode = true;
                                    _errorMessage = null;
                                    _image = null;
                                    _imageDetectedFoodItems = [];
                                    _imageDetectedFoodItemsWithNutrition = [];
                                  });
                                },
                        icon: const Icon(Icons.text_fields),
                        label: const Text('Text'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isTextInputMode
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[300],
                          foregroundColor:
                              _isTextInputMode
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Text input field with voice option
            if (_isTextInputMode)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Describe what you ate',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Example: "I ate 2 eggs with spinach and toast" or "Nilikula wali na maharage"',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _foodDescriptionController,
                              decoration: InputDecoration(
                                hintText: 'Enter food description...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_foodDescriptionController
                                        .text
                                        .isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed:
                                            _busy ? null : _clearTextInput,
                                      ),
                                    // Enhanced mic button with sound visualization
                                    Container(
                                      width: 40,
                                      height: 40,
                                      margin: const EdgeInsets.only(right: 8),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: .26,
                                            spreadRadius: _soundLevel * 1.5,
                                            color: Colors.black.withOpacity(.1),
                                          ),
                                        ],
                                        color:
                                            _isListening
                                                ? Colors.red
                                                : Colors.grey[300],
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(50),
                                        ),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          _isListening ? Icons.stop : Icons.mic,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        onPressed:
                                            _busy
                                                ? null
                                                : _isListening
                                                ? _stopRecording
                                                : _startRecording,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              maxLines: 3,
                              textInputAction: TextInputAction.done,
                              enabled: !_busy,
                            ),
                          ),
                        ],
                      ),
                      // Speech status indicators
                      if (_isListening)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            children: [
                              // Sound level bar
                              Container(
                                height: 4,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: Colors.grey[300],
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _soundLevel.clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Status text
                              Text(
                                _lastSpeechStatus,
                                style: TextStyle(
                                  color:
                                      _lastSpeechStatus.contains('Error')
                                          ? Colors.red
                                          : Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (!_isListening && _speechText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check,
                                  color: Colors.green[700],
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Ready to analyze',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed:
                            _busy
                                ? null
                                : () => _analyzeTextInput(
                                  _foodDescriptionController.text,
                                ),
                        icon: const Icon(Icons.search),
                        label: const Text('Log Food'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Image container
            if (!_isTextInputMode)
              RepaintBoundary(
                child:
                    _errorMessage != null
                        ? _buildErrorContainer()
                        : Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[200],
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child:
                              _image == null
                                  ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_enhance,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Take a photo or select from gallery',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                  : Hero(
                                    tag: 'food_image',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        _image!,
                                        fit: BoxFit.cover,
                                        cacheWidth: 800,
                                        cacheHeight: 800,
                                        filterQuality: FilterQuality.high,
                                      ),
                                    ),
                                  ),
                        ),
              ),

            if (!_isTextInputMode) const SizedBox(height: 16),

            // Camera and gallery buttons
            if (!_isTextInputMode)
              RepaintBoundary(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _busy ? null : _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        disabledBackgroundColor: Colors.grey,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _busy ? null : _pickImageFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondary,
                        disabledBackgroundColor: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Results section
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    _busy
                        ? _buildLoadingIndicator()
                        : currentDetectedFoodItems.isEmpty
                        ? _buildNoImageSelected()
                        : _buildFoodItemsList(
                          currentDetectedFoodItems,
                          currentDetectedFoodItemsWithNutrition,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContainer() {
    String errorMsg = _errorMessage ?? 'An error occurred';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                errorMsg,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Dismiss'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_image != null) {
                        setState(() {
                          _errorMessage = null;
                          _busy = true;
                          _nutritionBusy = true;
                        });
                        _analyzeImage(_image!);
                      } else if (_isTextInputMode) {
                        setState(() {
                          _errorMessage = null;
                          _busy = true;
                          _nutritionBusy = true;
                        });
                        _analyzeTextInput(_foodDescriptionController.text);
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            _isTextInputMode
                ? 'Analyzing food description...'
                : 'Analyzing image...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, dynamic value, {String? unit}) {
    String displayValue =
        (value != null && value is num)
            ? value.toStringAsFixed(1)
            : (value ?? 'N/A').toString();
    if (unit != null && displayValue != 'N/A') {
      displayValue += ' $unit';
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          Text(
            displayValue,
            style: TextStyle(color: Colors.grey[800], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNoImageSelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isTextInputMode ? Icons.no_food : Icons.image_search,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _isTextInputMode ? 'No food detected' : 'No image selected',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _isTextInputMode
                ? 'Enter a food description to detect food items'
                : 'Take a photo or select from gallery to analyze food',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItemsList(
    List<String> detectedFoodItems,
    List<Map<String, dynamic>> detectedFoodItemsWithNutrition,
  ) {
    if (detectedFoodItems.length == 1 &&
        detectedFoodItems[0] == 'NO_FOOD_DETECTED') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 64,
              color: Colors.orange[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Maybe no food detected',
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isTextInputMode
                  ? 'No food items were detected in your description.\nPlease try with a clearer description of what you ate.'
                  : 'The image does not appear to contain food items.\nPlease try uploading a photo of food.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed:
                  _isTextInputMode
                      ? () => _analyzeTextInput(_foodDescriptionController.text)
                      : () => _image != null ? _analyzeImage(_image!) : null,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[400],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (detectedFoodItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_food, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No food items detected',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isTextInputMode
                  ? 'Your description was processed, but no specific food items could be identified. Try being more specific.'
                  : 'The image may contain food, but specific items could not be identified.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed:
                  _isTextInputMode
                      ? () => _analyzeTextInput(_foodDescriptionController.text)
                      : () => _image != null ? _analyzeImage(_image!) : null,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[400],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RepaintBoundary(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _isTextInputMode
                      ? 'Food Items From Description'
                      : 'Food Items From Image',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: detectedFoodItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final String foodItem = _capitalize(detectedFoodItems[index]);

                Map<String, dynamic>? nutritionInfo;
                if (index < detectedFoodItemsWithNutrition.length) {
                  nutritionInfo = detectedFoodItemsWithNutrition[index];
                }

                return Card(
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      child: Icon(
                        Icons.restaurant,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      foodItem,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    subtitle:
                        nutritionInfo != null
                            ? Text(
                              'Calories: ${nutritionInfo['calories']?.toStringAsFixed(0) ?? 'N/A'} kcal | Tap for details',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            )
                            : _nutritionBusy
                            ? const Text('Loading nutrition data...')
                            : const Text('Nutrition data not available'),
                    children: [
                      if (_nutritionBusy &&
                          _imageDetectedFoodItemsWithNutrition.isEmpty &&
                          _textDetectedFoodItemsWithNutrition.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (nutritionInfo != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildNutritionRow(
                                'Calories',
                                nutritionInfo['calories'],
                                unit: 'kcal',
                              ),
                              _buildNutritionRow(
                                'Protein',
                                nutritionInfo['protein'],
                                unit: 'g',
                              ),
                              _buildNutritionRow(
                                'Carbs',
                                nutritionInfo['carbs'],
                                unit: 'g',
                              ),
                              _buildNutritionRow(
                                'Fats',
                                nutritionInfo['fats'],
                                unit: 'g',
                              ),
                              _buildNutritionRow(
                                'Saturated Fat',
                                nutritionInfo['saturatedFat'],
                                unit: 'g',
                              ),
                              _buildNutritionRow(
                                'Cholesterol',
                                nutritionInfo['cholesterol'],
                                unit: 'mg',
                              ),
                              _buildNutritionRow(
                                'Sugar',
                                nutritionInfo['sugar'],
                                unit: 'g',
                              ),
                              _buildNutritionRow(
                                'Fiber',
                                nutritionInfo['fiber'],
                                unit: 'g',
                              ),
                              _buildNutritionRow(
                                'Sodium',
                                nutritionInfo['sodium'],
                                unit: 'mg',
                              ),
                              _buildNutritionRow(
                                'Vitamin A',
                                nutritionInfo['vitaminA'],
                                unit: 'mcg RAE',
                              ),
                              _buildNutritionRow(
                                'Vitamin D',
                                nutritionInfo['vitaminD'],
                                unit: 'mcg',
                              ),
                              _buildNutritionRow(
                                'Vitamin C',
                                nutritionInfo['vitaminC'],
                                unit: 'mg',
                              ),
                              _buildNutritionRow(
                                'Vitamin E',
                                nutritionInfo['vitaminE'],
                                unit: 'mg AT',
                              ),
                              _buildNutritionRow(
                                'Vitamin B6',
                                nutritionInfo['vitaminB6'],
                                unit: 'mg',
                              ),
                              _buildNutritionRow(
                                'Vitamin B12',
                                nutritionInfo['vitaminB12'],
                                unit: 'mcg',
                              ),
                              _buildNutritionRow(
                                'Calcium (Ca)',
                                nutritionInfo['ca'],
                                unit: 'mg',
                              ),
                              _buildNutritionRow(
                                'Magnesium (Mg)',
                                nutritionInfo['mg'],
                                unit: 'mg',
                              ),
                              _buildNutritionRow(
                                'Potassium (K)',
                                nutritionInfo['k'],
                                unit: 'mg',
                              ),
                              _buildNutritionRow(
                                'Iron (Fe)',
                                nutritionInfo['fe'],
                                unit: 'mg',
                              ),
                              _buildNutritionRow(
                                'Zinc (Zn)',
                                nutritionInfo['zn'],
                                unit: 'mg',
                              ),
                              if (nutritionInfo['quantity'] != null &&
                                  nutritionInfo['quantity']
                                      .toString()
                                      .isNotEmpty)
                                _buildNutritionRow(
                                  'Quantity',
                                  nutritionInfo['quantity'],
                                ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  _logFoodItem(foodItem, nutritionInfo);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  'Log Food',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Nutrition data not available'),
                        ),
                    ],
                    onExpansionChanged: (expanded) {},
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '';
}

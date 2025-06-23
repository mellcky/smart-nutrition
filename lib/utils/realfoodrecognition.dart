// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:diet_app/services/gemini_service.dart';
// import 'package:flutter/foundation.dart';
// import 'dart:typed_data'; // Import this for Uint8List

// class FoodRecognitionScreen2 extends StatefulWidget {
//   const FoodRecognitionScreen2({super.key});
//   @override
//   State<FoodRecognitionScreen2> createState() => _FoodRecognitionScreen2State();
// }

// class _FoodRecognitionScreen2State extends State<FoodRecognitionScreen2> {
//   File? _image;
//   bool _busy = false;
//   bool _nutritionBusy = false; // New state for nutrition loading
//   String? _errorMessage;
//   List<String> _detectedFoodItems = [];
//   List<Map<String, dynamic>> _detectedFoodItemsWithNutrition = [];

//   // Text controller for food description input
//   final TextEditingController _foodDescriptionController =
//       TextEditingController();
//   bool _isTextInputMode = false;

//   // Cache for analyzed images to prevent duplicate analysis
//   final Map<String, List<String>> _imageAnalysisCache = {};

//   // Optimized ImagePicker with better configuration
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     // Pre-warm the image picker to reduce first-use latency
//     _preWarmImagePicker();
//   }

//   // Separate method to pre-warm the image picker
//   Future<void> _preWarmImagePicker() async {
//     try {
//       await Future.delayed(const Duration(milliseconds: 100));
//     } catch (_) {
//       // Ignore any errors during pre-warming
//     }
//   }

//   @override
//   void dispose() {
//     _foodDescriptionController.dispose();
//     super.dispose();
//   }

//   // Analyze text input using Gemini API
//   Future<void> _analyzeTextInput(String text) async {
//     if (text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a food description')),
//       );
//       return;
//     }

//     setState(() {
//       _busy = true;
//       _nutritionBusy = true;
//       _errorMessage = null;
//       _image = null; // Clear any previous image
//     });

//     try {
//       // Use Gemini service to extract food items from text
//       final foodItems = await GeminiService.extractFoodItemsFromText(text);

//       if (foodItems.isEmpty) {
//         throw Exception('No food items detected in the description');
//       }

//       // Extract just the names of the food items for display
//       final List<String> foodNames =
//           foodItems
//               .map((item) => item['name'] as String)
//               .where((name) => name.isNotEmpty)
//               .toList();

//       if (mounted) {
//         setState(() {
//           _detectedFoodItems = foodNames;
//           _detectedFoodItemsWithNutrition = foodItems;
//           _busy = false;
//           _nutritionBusy = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _busy = false;
//           _nutritionBusy = false;
//           _errorMessage = 'Error analyzing text: $e';
//         });

//         // Format error message to prevent overflow
//         String errorMsg = e.toString();
//         if (errorMsg.length > 100) {
//           errorMsg = '${errorMsg.substring(0, 100)}...';
//         }

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.error_outline, color: Colors.white),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     'Error analyzing text: $errorMsg',
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 5),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//         debugPrint('Text analysis error: $e');
//       }
//     }
//   }

//   // Take a photo using camera with improved quality
//   Future<void> _takePhoto() async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: ImageSource.camera,
//         imageQuality: 90, // High quality for food recognition
//         maxWidth: 1200, // Limit width for better performance
//         maxHeight: 1200, // Limit height for better performance
//         preferredCameraDevice:
//             CameraDevice.rear, // Use rear camera for better quality
//       );

//       if (pickedFile != null) {
//         setState(() {
//           _image = File(pickedFile.path);
//           _busy = true;
//           _nutritionBusy = true; // Start nutrition loading
//           _errorMessage = null;
//         });
//         await _analyzeImage(_image!);
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error accessing camera: $e';
//       });
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error accessing camera: $e')));
//     }
//   }

//   // Pick image from gallery with improved quality
//   Future<void> _pickImageFromGallery() async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 90, // High quality for food recognition
//         maxWidth: 1200, // Limit width for better performance
//         maxHeight: 1200, // Limit height for better performance
//       );

//       if (pickedFile != null) {
//         setState(() {
//           _image = File(pickedFile.path);
//           _busy = true;
//           _nutritionBusy = true; // Start nutrition loading
//           _errorMessage = null;
//         });
//         await _analyzeImage(_image!);
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error accessing gallery: $e';
//       });
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error accessing gallery: $e')));
//     }
//   }

//   // Analyze image using Gemini API with optimized performance
//   Future<void> _analyzeImage(File image) async {
//     if (!mounted) return;

//     try {
//       // Validate image file
//       if (!await image.exists()) {
//         throw Exception('Image file does not exist');
//       }

//       // Check if file is too large (>10MB)
//       final fileSize = await image.length();
//       if (fileSize > 10 * 1024 * 1024) {
//         throw Exception('Image file is too large (max 10MB)');
//       }

//       // Check cache first to avoid redundant API calls
//       final String imagePath = image.path;
//       if (_imageAnalysisCache.containsKey(imagePath)) {
//         setState(() {
//           _detectedFoodItems = _imageAnalysisCache[imagePath]!;
//           _busy = false;
//         });
//         // Still load nutrition data even if cached
//         _loadNutritionData(image);
//         return;
//       }

//       // Read image bytes and determine MIME type on the main isolate
//       final Uint8List imageBytes = await image.readAsBytes();
//       String mimeType = 'image/jpeg'; // default
//       final String extension = image.path.split('.').last.toLowerCase();

//       switch (extension) {
//         case 'png':
//           mimeType = 'image/png';
//           break;
//         case 'jpg':
//         case 'jpeg':
//           mimeType = 'image/jpeg';
//           break;
//         case 'gif':
//           mimeType = 'image/gif';
//           break;
//         case 'webp':
//           mimeType = 'image/webp';
//           break;
//         default:
//           mimeType = 'image/jpeg';
//       }

//       // Use Gemini service to analyze the image with a prompt that first checks if the image contains food
//       final prompt =
//           '''First, determine if this image contains edible food items.

// If the image does NOT contain any food (e.g., it shows objects like trees, shoes, furniture, people, landscapes, or other non-food items), respond with exactly "NO_FOOD_DETECTED" and nothing else.

// Consider the following as food:
// - Any prepared meals or dishes
// - Raw ingredients (fruits, vegetables, meats, grains)
// - Packaged food products
// - Beverages (drinks, smoothies)
// - Snacks and desserts

// If the image DOES contain food, identify only the food items visible. List each item separately (like fish, stew, rice, etc.). Be specific about varieties when possible (e.g., "grilled chicken" instead of just "chicken"). Return only a simple list of food items without any additional analysis or description.''';

//       String response;
//       try {
//         // Use compute to move heavy processing to a separate isolate
//         response = await compute((Map<String, dynamic> params) async {
//           try {
//             final Uint8List bytes = params['imageBytes'] as Uint8List;
//             final String type = params['mimeType'] as String;
//             final String customPrompt = params['prompt'] as String;

//             return await GeminiService.analyzeImageFromBytes(
//               bytes,
//               type,
//               customPrompt: customPrompt,
//             );
//           } catch (e) {
//             return "ERROR: ${e.toString()}";
//           }
//         }, {'imageBytes': imageBytes, 'mimeType': mimeType, 'prompt': prompt});

//         // Check for error response from isolate
//         if (response.startsWith("ERROR:")) {
//           throw Exception(response.substring(6));
//         }
//       } catch (e) {
//         throw Exception('Failed to analyze image: $e');
//       }

//       List<String> foodItems;
//       try {
//         // Parse the response to extract food items
//         foodItems = await compute(_parseFoodItemsFromResponse, response);
//       } catch (e) {
//         throw Exception('Failed to parse response: $e');
//       }

//       // Cache the results
//       _imageAnalysisCache[imagePath] = foodItems;

//       if (mounted) {
//         setState(() {
//           _detectedFoodItems = foodItems;
//           _busy = false;
//         });

//         // Load nutrition data in background
//         _loadNutritionData(image);

//         // Show a snackbar if no food was detected
//         if (foodItems.length == 1 && foodItems[0] == 'NO_FOOD_DETECTED') {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Row(
//                 children: [
//                   Icon(Icons.warning_amber_rounded, color: Colors.white),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       'No food detected in this image. Please try with a food photo.',
//                     ),
//                   ),
//                 ],
//               ),
//               backgroundColor: Colors.orange[700],
//               duration: const Duration(seconds: 4),
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               action: SnackBarAction(
//                 label: 'OK',
//                 textColor: Colors.white,
//                 onPressed: () {},
//               ),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _busy = false;
//           _nutritionBusy = false;
//           _errorMessage = 'Error analyzing image: $e';
//         });
//         // Format error message to prevent overflow
//         String errorMsg = e.toString();
//         if (errorMsg.length > 100) {
//           errorMsg = '${errorMsg.substring(0, 100)}...';
//         }

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.error_outline, color: Colors.white),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     'Error analyzing image: $errorMsg',
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 5),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//         debugPrint('Image analysis error: $e');
//       }
//     }
//   }

//   // Load nutrition data for image
//   Future<void> _loadNutritionData(File image) async {
//     try {
//       final nutritionData = await GeminiService.extractFoodItemsFromImage(
//         image,
//       );

//       if (mounted) {
//         setState(() {
//           _detectedFoodItemsWithNutrition = nutritionData;
//           _nutritionBusy = false;

//           // Update food names from nutrition data if available
//           if (nutritionData.isNotEmpty) {
//             _detectedFoodItems =
//                 nutritionData
//                     .map((item) => item['name']?.toString() ?? '')
//                     .where((name) => name.isNotEmpty)
//                     .toList();
//           }
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _nutritionBusy = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Nutrition analysis failed: ${e.toString()}')),
//         );
//       }
//     }
//   }

//   // Helper method to parse food items from Gemini API response
//   List<String> _parseFoodItemsFromResponse(String response) {
//     // Check if the response indicates no food was detected
//     if (response.trim().toUpperCase().contains('NO_FOOD_DETECTED')) {
//       // Return a special marker that will be handled in the UI
//       return ['NO_FOOD_DETECTED'];
//     }

//     // Split the response by newlines, commas, or bullet points
//     List<String> items = [];

//     // Remove any markdown formatting
//     String cleanedResponse = response
//         .replaceAll('*', '')
//         .replaceAll('#', '')
//         .replaceAll('-', '');

//     // Try to split by common separators
//     if (cleanedResponse.contains('\n')) {
//       // Split by newlines
//       items =
//           cleanedResponse
//               .split('\n')
//               .map((item) => item.trim())
//               .where((item) => item.isNotEmpty)
//               .toList();
//     } else if (cleanedResponse.contains(',')) {
//       // Split by commas
//       items =
//           cleanedResponse
//               .split(',')
//               .map((item) => item.trim())
//               .where((item) => item.isNotEmpty)
//               .toList();
//     } else if (cleanedResponse.contains('•')) {
//       // Split by bullet points
//       items =
//           cleanedResponse
//               .split('•')
//               .map((item) => item.trim())
//               .where((item) => item.isNotEmpty)
//               .toList();
//     } else {
//       // Just use the whole response as a single item if no separators found
//       items = [cleanedResponse.trim()];
//     }

//     // Clean up items (remove numbers, extra punctuation)
//     items =
//         items
//             .map((item) {
//               // Remove numbering (e.g., "1. ", "2. ")
//               item = item.replaceAll(RegExp(r'^\d+\.\s*'), '');
//               // Remove trailing punctuation
//               item = item.replaceAll(RegExp(r'[.:]$'), '');
//               return item.trim();
//             })
//             .where((item) => item.isNotEmpty)
//             .toList();

//     return items;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Food Recognition'), centerTitle: true),
//       resizeToAvoidBottomInset: false,
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             // Input mode toggle
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed:
//                             _busy
//                                 ? null
//                                 : () {
//                                   setState(() {
//                                     _isTextInputMode = false;
//                                   });
//                                 },
//                         icon: const Icon(Icons.camera_alt),
//                         label: const Text('Image'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor:
//                               !_isTextInputMode
//                                   ? Theme.of(context).colorScheme.primary
//                                   : Colors.grey[300],
//                           foregroundColor:
//                               !_isTextInputMode
//                                   ? Theme.of(context).colorScheme.onPrimary
//                                   : Colors.black87,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed:
//                             _busy
//                                 ? null
//                                 : () {
//                                   setState(() {
//                                     _isTextInputMode = true;
//                                   });
//                                 },
//                         icon: const Icon(Icons.text_fields),
//                         label: const Text('Text'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor:
//                               _isTextInputMode
//                                   ? Theme.of(context).colorScheme.primary
//                                   : Colors.grey[300],
//                           foregroundColor:
//                               _isTextInputMode
//                                   ? Theme.of(context).colorScheme.onPrimary
//                                   : Colors.black87,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Text input field (visible when in text mode)
//             if (_isTextInputMode)
//               Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       Text(
//                         'Describe what you ate',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Theme.of(context).colorScheme.primary,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Example: "I ate 2 eggs with spinach and toast" or "Nilikula wali na maharage"',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey[600],
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       TextField(
//                         controller: _foodDescriptionController,
//                         decoration: InputDecoration(
//                           hintText: 'Enter food description...',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           filled: true,
//                           fillColor: Colors.grey[100],
//                         ),
//                         maxLines: 3,
//                         textInputAction: TextInputAction.done,
//                         enabled: !_busy,
//                       ),
//                       const SizedBox(height: 12),
//                       ElevatedButton.icon(
//                         onPressed:
//                             _busy
//                                 ? null
//                                 : () => _analyzeTextInput(
//                                   _foodDescriptionController.text,
//                                 ),
//                         icon: const Icon(Icons.search),
//                         label: const Text('Log Food'),
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           backgroundColor:
//                               Theme.of(context).colorScheme.primary,
//                           foregroundColor:
//                               Theme.of(context).colorScheme.onPrimary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//             // Image container (visible when in image mode)
//             if (!_isTextInputMode)
//               // Wrap with AspectRatio or a fixed height if Expanded is not suitable in a ListView
//               SizedBox(
//                 // Changed from Expanded
//                 height: 250, // Example fixed height
//                 child: RepaintBoundary(
//                   child:
//                       _errorMessage != null
//                           ? _buildErrorContainer()
//                           : Container(
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               color: Colors.grey[200],
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.1),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child:
//                                 _image == null
//                                     ? Center(
//                                       child: Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Icon(
//                                             Icons.camera_enhance,
//                                             size: 48,
//                                             color: Colors.grey[400],
//                                           ),
//                                           const SizedBox(height: 16),
//                                           Text(
//                                             'Take a photo or select from gallery',
//                                             style: TextStyle(
//                                               color: Colors.grey[600],
//                                             ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ],
//                                       ),
//                                     )
//                                     : Hero(
//                                       tag: 'food_image',
//                                       child: ClipRRect(
//                                         borderRadius: BorderRadius.circular(12),
//                                         child: Image.file(
//                                           _image!,
//                                           fit: BoxFit.cover,
//                                           cacheWidth: 800,
//                                           cacheHeight: 800,
//                                           filterQuality: FilterQuality.high,
//                                         ),
//                                       ),
//                                     ),
//                           ),
//                 ),
//               ),

//             // Only show camera/gallery buttons in image mode
//             if (!_isTextInputMode) const SizedBox(height: 16),

//             // Camera and gallery buttons (visible when in image mode)
//             if (!_isTextInputMode)
//               RepaintBoundary(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: _busy ? null : _takePhoto,
//                       icon: const Icon(Icons.camera_alt),
//                       label: const Text('Take Photo'),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                         backgroundColor: Theme.of(context).colorScheme.primary,
//                         foregroundColor:
//                             Theme.of(context).colorScheme.onPrimary,
//                         disabledBackgroundColor: Colors.grey,
//                       ),
//                     ),
//                     ElevatedButton.icon(
//                       onPressed: _busy ? null : _pickImageFromGallery,
//                       icon: const Icon(Icons.photo_library),
//                       label: const Text('Gallery'),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                         backgroundColor:
//                             Theme.of(context).colorScheme.secondary,
//                         foregroundColor:
//                             Theme.of(context).colorScheme.onSecondary,
//                         disabledBackgroundColor: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             const SizedBox(height: 16),

//             // Loading indicator or analysis results
//             // Changed from Expanded to a fixed height or a flexible widget within ListView
//             SizedBox(
//               // Changed from Expanded
//               height: 300, // Example fixed height for results area
//               child: AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 300),
//                 child:
//                     _busy
//                         ? _buildLoadingIndicator()
//                         : _isTextInputMode
//                         ? (_detectedFoodItems.isEmpty
//                             ? _buildNoImageSelected()
//                             : _buildFoodItemsList())
//                         : (_image == null
//                             ? _buildNoImageSelected()
//                             : _buildFoodItemsList()),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Extracted method for error display
//   Widget _buildErrorContainer() {
//     // Format error message to prevent overflow
//     String errorMsg = _errorMessage ?? 'An error occurred';

//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.red.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.red.withOpacity(0.5)),
//       ),
//       child: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.error_outline, color: Colors.red, size: 48),
//               const SizedBox(height: 16),
//               Text(
//                 errorMsg,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(color: Colors.red),
//                 maxLines: 5,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       setState(() {
//                         _errorMessage = null;
//                       });
//                     },
//                     icon: const Icon(Icons.close),
//                     label: const Text('Dismiss'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       if (_image != null) {
//                         setState(() {
//                           _errorMessage = null;
//                           _busy = true;
//                         });
//                         _analyzeImage(_image!);
//                       }
//                     },
//                     icon: const Icon(Icons.refresh),
//                     label: const Text('Try Again'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Extracted method for loading indicator
//   Widget _buildLoadingIndicator() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const CircularProgressIndicator(),
//           const SizedBox(height: 16),
//           Text(
//             _isTextInputMode
//                 ? 'Analyzing food description...'
//                 : 'Analyzing image...',
//             style: TextStyle(color: Colors.grey[600]),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper method to build a nutrition information row
//   Widget _buildNutritionRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
//           ),
//           Text(value, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
//         ],
//       ),
//     );
//   }

//   // Extracted method for no image selected state
//   Widget _buildNoImageSelected() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             _isTextInputMode ? Icons.no_food : Icons.image_search,
//             size: 64,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             _isTextInputMode ? 'No food detected' : 'No image selected',
//             style: TextStyle(color: Colors.grey[600], fontSize: 16),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _isTextInputMode
//                 ? 'Enter a food description to detect food items'
//                 : 'Take a photo or select from gallery to analyze food',
//             style: TextStyle(color: Colors.grey[500], fontSize: 14),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   // Extracted method for food items list
//   Widget _buildFoodItemsList() {
//     // Check if the special marker for non-food images is present
//     if (_detectedFoodItems.length == 1 &&
//         _detectedFoodItems[0] == 'NO_FOOD_DETECTED') {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.image_not_supported,
//               size: 64,
//               color: Colors.orange[400],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Maybe no food detected',
//               style: TextStyle(
//                 color: Colors.orange[700],
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _isTextInputMode
//                   ? 'No food items were detected in your description.\nPlease try with a clearer description of what you ate.'
//                   : 'The image does not appear to contain food items.\nPlease try uploading a photo of food.',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey[600], fontSize: 14),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed:
//                   _isTextInputMode
//                       ? () => _analyzeTextInput(_foodDescriptionController.text)
//                       : () => _image != null ? _analyzeImage(_image!) : null,
//               icon: const Icon(Icons.refresh),
//               label: const Text('Try Again'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange[400],
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     // Regular empty check
//     if (_detectedFoodItems.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.no_food, size: 64, color: Colors.grey[400]),
//             const SizedBox(height: 16),
//             Text(
//               'No food items detected',
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _isTextInputMode
//                   ? 'Your description was processed, but no specific food items could be identified. Try being more specific.'
//                   : 'The image may contain food, but specific items could not be identified.',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey[600], fontSize: 14),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed:
//                   _isTextInputMode
//                       ? () => _analyzeTextInput(_foodDescriptionController.text)
//                       : () => _image != null ? _analyzeImage(_image!) : null,
//               icon: const Icon(Icons.refresh),
//               label: const Text('Try Again'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue[400],
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return RepaintBoundary(
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.check_circle,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   _isTextInputMode
//                       ? 'Food Items From Description'
//                       : 'Food Items From Image',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             // Use ListView.separated for better performance
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: _detectedFoodItems.length,
//               separatorBuilder: (context, index) => const SizedBox(height: 8),
//               itemBuilder: (context, index) {
//                 // Use const constructor for static parts and cache dynamic parts
//                 final String foodItem = _capitalize(_detectedFoodItems[index]);

//                 // Get nutritional information if available
//                 Map<String, dynamic>? nutritionInfo;
//                 if (index < _detectedFoodItemsWithNutrition.length) {
//                   nutritionInfo = _detectedFoodItemsWithNutrition[index];
//                 }

//                 return Card(
//                   elevation: 2,
//                   margin: EdgeInsets.zero,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: ExpansionTile(
//                     leading: CircleAvatar(
//                       backgroundColor: Theme.of(
//                         context,
//                       ).colorScheme.primary.withOpacity(0.2),
//                       child: Icon(
//                         Icons.restaurant,
//                         color: Theme.of(context).colorScheme.primary,
//                       ),
//                     ),
//                     title: Text(
//                       foodItem,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w500,
//                         fontSize: 16,
//                       ),
//                     ),
//                     subtitle:
//                         nutritionInfo != null
//                             ? Text(
//                               'Calories: ${nutritionInfo['calories'] ?? 'N/A'} | Tap for details',
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                                 fontSize: 12,
//                               ),
//                             )
//                             : _nutritionBusy
//                             ? const Text('Loading nutrition data...')
//                             : const Text('Nutrition data not available'),
//                     children: [
//                       if (_nutritionBusy)
//                         const Padding(
//                           padding: EdgeInsets.all(16.0),
//                           child: Center(child: CircularProgressIndicator()),
//                         )
//                       else if (nutritionInfo != null)
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16.0,
//                             vertical: 8.0,
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _buildNutritionRow(
//                                 'Calories',
//                                 '${nutritionInfo['calories'] ?? 'N/A'} kcal',
//                               ),
//                               _buildNutritionRow(
//                                 'Protein',
//                                 '${nutritionInfo['protein'] ?? 'N/A'} g',
//                               ),
//                               _buildNutritionRow(
//                                 'Carbs',
//                                 '${nutritionInfo['carbs'] ?? 'N/A'} g',
//                               ),
//                               _buildNutritionRow(
//                                 'Fats',
//                                 '${nutritionInfo['fats'] ?? 'N/A'} g',
//                               ),
//                               if (nutritionInfo['quantity'] != null &&
//                                   nutritionInfo['quantity']
//                                       .toString()
//                                       .isNotEmpty)
//                                 _buildNutritionRow(
//                                   'Quantity',
//                                   nutritionInfo['quantity'],
//                                 ),
//                               const SizedBox(height: 8),
//                               ElevatedButton(
//                                 onPressed: () {
//                                   _logFoodItem(foodItem);
//                                 },
//                                 child: const Text('Log Food'),
//                               ),
//                             ],
//                           ),
//                         )
//                       else
//                         const Padding(
//                           padding: EdgeInsets.all(16.0),
//                           child: Text('Nutrition data not available'),
//                         ),
//                     ],
//                     onExpansionChanged: (expanded) {
//                       // Could add analytics or other functionality here
//                     },
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _capitalize(String s) =>
//       s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '';

//   void _logFoodItem(String foodName) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('Logged: $foodName')));
//     // Here you would add actual logging logic
//   }
// }

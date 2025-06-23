// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:http/http.dart' as http;
// import '../models/user_profile.dart';
// import '../models/food_item.dart';
// import '../models/meal_plan.dart';

// class GeminiService {
//   // Store API key securely - consider using environment variables or secure storage
//   static const String _apiKey =
//       'AIzaSyAwJlcudkNBx36XBT455Sh02VSXr1GsbPg'; // Replace with your actual key
//   static const String _baseUrl =
//       'https://generativelanguage.googleapis.com/v1beta/models';

//   // Updated endpoint for Gemini 1.5 Flash (supports vision)
//   static String get _endpoint =>
//       '$_baseUrl/gemini-1.5-flash-latest:generateContent?key=$_apiKey';

//   /// Analyzes an image from a base64 string
//   static Future<String> analyzeImageFromBase64(
//     String base64Image, {
//     String? customPrompt,
//   }) async {
//     try {
//       final prompt =
//           customPrompt ??
//           'Describe the food in this image clearly and identify any ingredients you can see.';

//       final response = await http.post(
//         Uri.parse(_endpoint),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'contents': [
//             {
//               'parts': [
//                 {
//                   'inlineData': {'mimeType': 'image/jpeg', 'data': base64Image},
//                 },
//                 {'text': prompt},
//               ],
//             },
//           ],
//           'generationConfig': {
//             'temperature': 0.4,
//             'topK': 32,
//             'topP': 1,
//             'maxOutputTokens': 4096,
//           },
//           'safetySettings': [
//             {
//               'category': 'HARM_CATEGORY_HARASSMENT',
//               'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
//             },
//             {
//               'category': 'HARM_CATEGORY_HATE_SPEECH',
//               'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
//             },
//             {
//               'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
//               'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
//             },
//             {
//               'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
//               'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
//             },
//           ],
//         }),
//       );

//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);

//         // Check if response has the expected structure
//         if (json['candidates'] != null &&
//             json['candidates'].isNotEmpty &&
//             json['candidates'][0]['content'] != null &&
//             json['candidates'][0]['content']['parts'] != null &&
//             json['candidates'][0]['content']['parts'].isNotEmpty) {
//           return json['candidates'][0]['content']['parts'][0]['text'];
//         } else {
//           throw Exception('Unexpected response structure: ${response.body}');
//         }
//       } else {
//         throw Exception(
//           'API request failed with status ${response.statusCode}: ${response.body}',
//         );
//       }
//     } catch (e) {
//       throw Exception('Failed to analyze image: $e');
//     }
//   }

//   /// Analyzes an image from a File object
//   static Future<String> analyzeImageFromFile(
//     File imageFile, {
//     String? customPrompt,
//   }) async {
//     try {
//       // Read file as bytes
//       final Uint8List imageBytes = await imageFile.readAsBytes();

//       // Convert to base64
//       final String base64Image = base64Encode(imageBytes);

//       // Determine MIME type based on file extension
//       String mimeType = 'image/jpeg'; // default
//       final String extension = imageFile.path.split('.').last.toLowerCase();

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

//       final prompt =
//           customPrompt ??
//           'Describe the food in this image clearly and identify any ingredients you can see.';

//       final response = await http.post(
//         Uri.parse(_endpoint),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'contents': [
//             {
//               'parts': [
//                 {
//                   'inlineData': {'mimeType': mimeType, 'data': base64Image},
//                 },
//                 {'text': prompt},
//               ],
//             },
//           ],
//           'generationConfig': {
//             'temperature': 0.4,
//             'topK': 32,
//             'topP': 1,
//             'maxOutputTokens': 4096,
//           },
//         }),
//       );

//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);

//         if (json['candidates'] != null &&
//             json['candidates'].isNotEmpty &&
//             json['candidates'][0]['content'] != null &&
//             json['candidates'][0]['content']['parts'] != null &&
//             json['candidates'][0]['content']['parts'].isNotEmpty) {
//           return json['candidates'][0]['content']['parts'][0]['text'];
//         } else {
//           throw Exception('Unexpected response structure: ${response.body}');
//         }
//       } else {
//         throw Exception(
//           'API request failed with status ${response.statusCode}: ${response.body}',
//         );
//       }
//     } catch (e) {
//       throw Exception('Failed to analyze image from file: $e');
//     }
//   }

//   /// Analyzes an image from bytes with specified MIME type
//   static Future<String> analyzeImageFromBytes(
//     Uint8List imageBytes,
//     String mimeType, {
//     String? customPrompt,
//   }) async {
//     try {
//       final String base64Image = base64Encode(imageBytes);
//       return await analyzeImageFromBase64WithMimeType(
//         base64Image,
//         mimeType,
//         customPrompt: customPrompt,
//       );
//     } catch (e) {
//       throw Exception('Failed to analyze image from bytes: $e');
//     }
//   }

//   /// Helper method for base64 analysis with custom MIME type
//   static Future<String> analyzeImageFromBase64WithMimeType(
//     String base64Image,
//     String mimeType, {
//     String? customPrompt,
//   }) async {
//     try {
//       final prompt =
//           customPrompt ??
//           'Describe the food in this image clearly and identify any ingredients you can see.';

//       final response = await http.post(
//         Uri.parse(_endpoint),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'contents': [
//             {
//               'parts': [
//                 {
//                   'inlineData': {'mimeType': mimeType, 'data': base64Image},
//                 },
//                 {'text': prompt},
//               ],
//             },
//           ],
//           'generationConfig': {
//             'temperature': 0.4,
//             'topK': 32,
//             'topP': 1,
//             'maxOutputTokens': 4096,
//           },
//         }),
//       );

//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);

//         if (json['candidates'] != null &&
//             json['candidates'].isNotEmpty &&
//             json['candidates'][0]['content'] != null &&
//             json['candidates'][0]['content']['parts'] != null &&
//             json['candidates'][0]['content']['parts'].isNotEmpty) {
//           return json['candidates'][0]['content']['parts'][0]['text'];
//         } else {
//           throw Exception('Unexpected response structure: ${response.body}');
//         }
//       } else {
//         throw Exception(
//           'API request failed with status ${response.statusCode}: ${response.body}',
//         );
//       }
//     } catch (e) {
//       throw Exception('Failed to analyze image: $e');
//     }
//   }

//   /// Generates a meal plan based on user profile
//   static Future<String> generateMealPlan(
//     UserProfile profile, {
//     bool isWeekly = false,
//   }) async {
//     try {
//       // Build a prompt based on user profile
//       String prompt = _buildMealPlanPrompt(profile, isWeekly);

//       final response = await http.post(
//         Uri.parse(_endpoint),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'contents': [
//             {
//               'parts': [
//                 {'text': prompt},
//               ],
//             },
//           ],
//           'generationConfig': {
//             'temperature': 0.7,
//             'topK': 32,
//             'topP': 1,
//             'maxOutputTokens': 4096,
//           },
//         }),
//       );

//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);

//         if (json['candidates'] != null &&
//             json['candidates'].isNotEmpty &&
//             json['candidates'][0]['content'] != null &&
//             json['candidates'][0]['content']['parts'] != null &&
//             json['candidates'][0]['content']['parts'].isNotEmpty) {
//           return json['candidates'][0]['content']['parts'][0]['text'];
//         } else {
//           throw Exception('Unexpected response structure: ${response.body}');
//         }
//       } else {
//         throw Exception(
//           'API request failed with status ${response.statusCode}: ${response.body}',
//         );
//       }
//     } catch (e) {
//       throw Exception('Failed to generate meal plan: $e');
//     }
//   }

//   /// Builds a prompt for meal plan generation based on user profile
//   static String _buildMealPlanPrompt(UserProfile profile, bool isWeekly) {
//     final StringBuilder = StringBuffer();

//     // Basic information
//     StringBuilder.write(
//       'Generate a ${isWeekly ? "weekly" : "daily"} meal plan for a ',
//     );
//     if (profile.age != null) StringBuilder.write('${profile.age}-year-old ');
//     if (profile.gender != null) StringBuilder.write('${profile.gender} ');

//     // Health conditions
//     if (profile.healthConditions != null &&
//         profile.healthConditions!.isNotEmpty) {
//       StringBuilder.write(
//         'with the following health conditions: ${profile.healthConditions!.join(", ")}. ',
//       );
//     }

//     // Dietary restrictions
//     if (profile.dietaryRestrictions != null &&
//         profile.dietaryRestrictions!.isNotEmpty) {
//       StringBuilder.write(
//         'They have the following dietary restrictions: ${profile.dietaryRestrictions!.join(", ")}. ',
//       );
//     }

//     // Activity level and goals
//     if (profile.activityLevel != null) {
//       StringBuilder.write('Their activity level is ${profile.activityLevel}. ');
//     }

//     if (profile.dietaryGoals != null && profile.dietaryGoals!.isNotEmpty) {
//       StringBuilder.write(
//         'Their dietary goals are: ${profile.dietaryGoals!.join(", ")}. ',
//       );
//     }

//     // Calorie goal
//     if (profile.totalCaloriesGoal != null) {
//       StringBuilder.write(
//         'Their daily calorie goal is ${profile.totalCaloriesGoal} calories. ',
//       );
//     }

//     // Specify Tanzanian food preferences
//     StringBuilder.write(
//       'Please suggest foods that are commonly available in Tanzania and align with Tanzanian cultural preferences and cuisine. Focus on local ingredients, traditional dishes, and foods that are part of the everyday Tanzanian diet. ',
//     );

//     // Add specific examples of Tanzanian foods and ingredients
//     StringBuilder.write(
//       'Include traditional Tanzanian dishes like ugali (cornmeal porridge), pilau (spiced rice), nyama choma (grilled meat), chapati (flatbread), and wali na maharage (rice and beans). Use local ingredients such as cassava, plantains, sweet potatoes, beans, maize, rice, millet, sorghum, coconut, and various tropical fruits. For proteins, include options like tilapia, dagaa (small dried fish), beef, chicken, and beans that are commonly consumed in Tanzania. ',
//     );

//     // Add instructions about Tanzanian meal patterns and nutrition
//     StringBuilder.write(
//       'Structure the meals according to typical Tanzanian eating patterns, where lunch is often the main meal of the day. Include vegetables like mchicha (amaranth greens), sukuma wiki (collard greens), and okra that are commonly consumed in Tanzania. For beverages, suggest options like chai (spiced tea), fresh tropical fruit juices, or uji (porridge) that are popular in Tanzania. Balance traditional foods with nutritional requirements to create a healthy, culturally appropriate meal plan. ',
//     );

//     // Format instructions
//     StringBuilder.write('''
// Please provide a structured ${isWeekly ? "weekly" : "daily"} meal plan with the following details:

// ${isWeekly ? "For each day of the week (Monday to Sunday):" : ""}
// 1. Breakfast: Include food items with their nutritional information (calories, protein, fats, carbs)
// 2. Lunch: Include food items with their nutritional information
// 3. Snacks: Include food items with their nutritional information
// 4. Dinner: Include food items with their nutritional information

// For each meal, include:
// - Brief preparation instructions
// - Health benefits, especially related to their health conditions or goals

// Format the response as JSON with the following structure:
// {
//   ${isWeekly ? '"dailyPlans": [' : ''}
//   ${isWeekly ? '  {' : ''}
//     "date": "YYYY-MM-DD",
//     "meals": [
//       {
//         "mealType": "Breakfast/Lunch/Dinner/Snack",
//         "foodItems": [
//           {
//             "foodItem": "Name of food",
//             "foodType": "Category",
//             "calories": 0,
//             "protein": 0,
//             "fats": 0,
//             "carbs": 0
//           }
//         ],
//         "instructions": "Brief preparation instructions",
//         "healthBenefits": "Health benefits of this meal"
//       }
//     ]
//   ${isWeekly ? '  }' : ''}
//   ${isWeekly ? ']' : ''}
// }
// ''');

//     return StringBuilder.toString();
//   }

//   /// Parse the JSON response from Gemini into a DailyMealPlan or WeeklyMealPlan object
//   static dynamic parseMealPlanResponse(String response, bool isWeekly) {
//     try {
//       // Clean up the response if needed (remove markdown formatting, etc.)
//       String cleanedResponse = response;

//       // If the response contains a code block, extract just the JSON part
//       if (response.contains('```json')) {
//         cleanedResponse = response.split('```json')[1].split('```')[0].trim();
//       } else if (response.contains('```')) {
//         cleanedResponse = response.split('```')[1].split('```')[0].trim();
//       }

//       // Try to find JSON in the response if it's not properly formatted
//       if (!cleanedResponse.trim().startsWith('{')) {
//         final jsonStartIndex = cleanedResponse.indexOf('{');
//         final jsonEndIndex = cleanedResponse.lastIndexOf('}');

//         if (jsonStartIndex >= 0 && jsonEndIndex > jsonStartIndex) {
//           cleanedResponse = cleanedResponse.substring(
//             jsonStartIndex,
//             jsonEndIndex + 1,
//           );
//         }
//       }

//       // Try to parse the JSON
//       Map<String, dynamic> jsonData;
//       try {
//         jsonData = jsonDecode(cleanedResponse);
//       } catch (e) {
//         print('Error decoding JSON: $e');
//         print('Response: $cleanedResponse');

//         // If we can't parse the JSON, create a default structure
//         if (isWeekly) {
//           return _createDefaultWeeklyPlan();
//         } else {
//           return _createDefaultDailyPlan();
//         }
//       }

//       // Check if the JSON has the expected structure
//       if (isWeekly) {
//         if (!jsonData.containsKey('dailyPlans')) {
//           print('Weekly meal plan JSON missing dailyPlans key');
//           // If the structure is wrong, wrap it in the expected structure
//           if (jsonData.containsKey('meals')) {
//             // It might be a single day plan
//             jsonData = {
//               'dailyPlans': [jsonData],
//             };
//           } else {
//             return _createDefaultWeeklyPlan();
//           }
//         }
//         return WeeklyMealPlan.fromJson(jsonData);
//       } else {
//         if (!jsonData.containsKey('meals') && !jsonData.containsKey('date')) {
//           print('Daily meal plan JSON missing required keys');
//           // If the structure is wrong, wrap it in the expected structure
//           List<dynamic> meals = [];

//           // Safely extract meals from dailyPlans if available
//           if (jsonData.containsKey('dailyPlans') &&
//               jsonData['dailyPlans'] is List &&
//               (jsonData['dailyPlans'] as List).isNotEmpty) {
//             var firstPlan = (jsonData['dailyPlans'] as List)[0];
//             if (firstPlan is Map<String, dynamic> &&
//                 firstPlan.containsKey('meals') &&
//                 firstPlan['meals'] is List) {
//               meals = firstPlan['meals'] as List;
//             }
//           }

//           jsonData = {'date': DateTime.now().toIso8601String(), 'meals': meals};
//         }
//         return DailyMealPlan.fromJson(jsonData);
//       }
//     } catch (e) {
//       print('Failed to parse meal plan response: $e');
//       // Return a default plan instead of throwing an exception
//       if (isWeekly) {
//         return _createDefaultWeeklyPlan();
//       } else {
//         return _createDefaultDailyPlan();
//       }
//     }
//   }

//   /// Create a default daily meal plan
//   static DailyMealPlan _createDefaultDailyPlan() {
//     return DailyMealPlan(
//       date: DateTime.now(),
//       meals: [
//         Meal(
//           mealType: 'Breakfast',
//           foodItems: [],
//           instructions: 'Could not generate meal plan. Please try again.',
//           healthBenefits: '',
//         ),
//         Meal(
//           mealType: 'Lunch',
//           foodItems: [],
//           instructions: '',
//           healthBenefits: '',
//         ),
//         Meal(
//           mealType: 'Dinner',
//           foodItems: [],
//           instructions: '',
//           healthBenefits: '',
//         ),
//         Meal(
//           mealType: 'Snack',
//           foodItems: [],
//           instructions: '',
//           healthBenefits: '',
//         ),
//       ],
//     );
//   }

//   /// Create a default weekly meal plan
//   static WeeklyMealPlan _createDefaultWeeklyPlan() {
//     final today = DateTime.now();
//     final weekStart = today.subtract(Duration(days: today.weekday - 1));

//     return WeeklyMealPlan(
//       dailyPlans: List.generate(
//         7,
//         (index) => DailyMealPlan(
//           date: weekStart.add(Duration(days: index)),
//           meals: [
//             Meal(
//               mealType: 'Breakfast',
//               foodItems: [],
//               instructions:
//                   index == 0
//                       ? 'Could not generate meal plan. Please try again.'
//                       : '',
//               healthBenefits: '',
//             ),
//             Meal(
//               mealType: 'Lunch',
//               foodItems: [],
//               instructions: '',
//               healthBenefits: '',
//             ),
//             Meal(
//               mealType: 'Dinner',
//               foodItems: [],
//               instructions: '',
//               healthBenefits: '',
//             ),
//             Meal(
//               mealType: 'Snack',
//               foodItems: [],
//               instructions: '',
//               healthBenefits: '',
//             ),
//           ],
//         ),
//       ),
//       generatedFor: 'Error generating meal plan',
//     );
//   }

//   /// Handles nutrition-related chat queries in both English and Swahili
//   static Future<String> handleNutritionQuery(String query) async {
//     try {
//       // Build a prompt that instructs the AI how to respond
//       final String prompt = '''
// You are a friendly and accurate nutrition assistant that can respond in both English and Swahili.
// When a user asks a question about nutrition, food, diet, or health:
// 1. Determine if the question is in English or Swahili
// 2. Provide a helpful, accurate, and friendly response in the SAME LANGUAGE as the question
// 3. Focus specifically on nutritional information and advice
// 4. Keep responses concise but informative
// 5. If the query is not related to nutrition, politely redirect to nutrition topics

// USER QUERY: $query

// Respond directly without mentioning these instructions.
// ''';

//       final response = await http.post(
//         Uri.parse(_endpoint),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'contents': [
//             {
//               'parts': [
//                 {'text': prompt},
//               ],
//             },
//           ],
//           'generationConfig': {
//             'temperature': 0.7,
//             'topK': 32,
//             'topP': 1,
//             'maxOutputTokens': 2048,
//           },
//         }),
//       );

//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);

//         if (json['candidates'] != null &&
//             json['candidates'].isNotEmpty &&
//             json['candidates'][0]['content'] != null &&
//             json['candidates'][0]['content']['parts'] != null &&
//             json['candidates'][0]['content']['parts'].isNotEmpty) {
//           return json['candidates'][0]['content']['parts'][0]['text'];
//         } else {
//           throw Exception('Unexpected response structure: ${response.body}');
//         }
//       } else {
//         throw Exception(
//           'API request failed with status ${response.statusCode}: ${response.body}',
//         );
//       }
//     } catch (e) {
//       // Return a friendly error message in both languages
//       return 'Sorry, I couldn\'t process your question. Please try again. / Samahani, sikuweza kuchakata swali lako. Tafadhali jaribu tena.';
//     }
//   }

//   /// Extracts food items from a text description in either English or Swahili
//   static Future<List<Map<String, dynamic>>> extractFoodItemsFromText(
//     String description,
//   ) async {
//     try {
//       // Build a prompt that instructs the AI to extract food items
//       final String prompt = '''
// You are a nutrition analysis assistant specialized in identifying food items from text descriptions in both English and Swahili.

// TASK:
// 1. Analyze the following food description: "$description"
// 2. Identify all food items mentioned (ingredients, dishes, beverages)
// 3. For each food item, estimate its nutritional content based on standard portions
// 4. Focus on Tanzanian and East African foods when possible
// 5. If the description is in Swahili, still provide the analysis in English format but preserve the original food names

// FORMAT YOUR RESPONSE AS JSON:
// {
//   "language": "english" or "swahili",
//   "foodItems": [
//     {
//       "name": "food item name",
//       "quantity": "estimated quantity (if mentioned)",
//       "calories": estimated calories,
//       "protein": estimated protein in grams,
//       "carbs": estimated carbs in grams,
//       "fats": estimated fats in grams
//     },
//     ...
//   ]
// }

// Only return the JSON with no additional text or explanation.
// ''';

//       final response = await http.post(
//         Uri.parse(_endpoint),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'contents': [
//             {
//               'parts': [
//                 {'text': prompt},
//               ],
//             },
//           ],
//           'generationConfig': {
//             'temperature': 0.2,
//             'topK': 32,
//             'topP': 1,
//             'maxOutputTokens': 2048,
//           },
//         }),
//       );

//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);

//         if (json['candidates'] != null &&
//             json['candidates'].isNotEmpty &&
//             json['candidates'][0]['content'] != null &&
//             json['candidates'][0]['content']['parts'] != null &&
//             json['candidates'][0]['content']['parts'].isNotEmpty) {
//           String responseText =
//               json['candidates'][0]['content']['parts'][0]['text'];

//           // Clean up the response if needed (remove markdown formatting, etc.)
//           if (responseText.contains('```json')) {
//             responseText =
//                 responseText.split('```json')[1].split('```')[0].trim();
//           } else if (responseText.contains('```')) {
//             responseText = responseText.split('```')[1].split('```')[0].trim();
//           }

//           // Try to find JSON in the response if it's not properly formatted
//           if (!responseText.trim().startsWith('{')) {
//             final jsonStartIndex = responseText.indexOf('{');
//             final jsonEndIndex = responseText.lastIndexOf('}');

//             if (jsonStartIndex >= 0 && jsonEndIndex > jsonStartIndex) {
//               responseText = responseText.substring(
//                 jsonStartIndex,
//                 jsonEndIndex + 1,
//               );
//             }
//           }

//           try {
//             final parsedJson = jsonDecode(responseText);
//             if (parsedJson.containsKey('foodItems') &&
//                 parsedJson['foodItems'] is List) {
//               return List<Map<String, dynamic>>.from(parsedJson['foodItems']);
//             } else {
//               return [];
//             }
//           } catch (e) {
//             print('Error parsing food items JSON: $e');
//             return [];
//           }
//         }
//       }

//       // Return empty list if there was an error or no food items were found
//       return [];
//     } catch (e) {
//       print('Error extracting food items: $e');
//       return [];
//     }
//   }
// }

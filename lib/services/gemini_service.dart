import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../models/food_item.dart';
import '../models/meal_plan.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyAwJlcudkNBx36XBT455Sh02VSXr1GsbPg';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static String get _endpoint =>
      '$_baseUrl/gemini-1.5-flash-latest:generateContent?key=$_apiKey';

  /// Analyzes an image from a base64 string
  static Future<String> analyzeImageFromBase64(
    String base64Image, {
    String? customPrompt,
  }) async {
    try {
      final prompt =
          customPrompt ??
          'Describe the food in this image clearly and identify any ingredients you can see.';

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'inlineData': {'mimeType': 'image/jpeg', 'data': base64Image},
                },
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.4,
            'topK': 32,
            'topP': 1,
            'maxOutputTokens': 4096,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['candidates'] != null &&
            json['candidates'].isNotEmpty &&
            json['candidates'][0]['content'] != null &&
            json['candidates'][0]['content']['parts'] != null &&
            json['candidates'][0]['content']['parts'].isNotEmpty) {
          return json['candidates'][0]['content']['parts'][0]['text'];
        } else {
          throw Exception('Unexpected response structure: ${response.body}');
        }
      } else {
        throw Exception(
          'API request failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to analyze image: ${e.toString()}');
    }
  }

  /// Analyzes an image from a File object
  static Future<String> analyzeImageFromFile(
    File imageFile, {
    String? customPrompt,
  }) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      String mimeType = 'image/jpeg';
      final String extension = imageFile.path.split('.').last.toLowerCase();

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

      return await analyzeImageFromBytesAndMimeType(
        imageBytes,
        mimeType,
        customPrompt: customPrompt,
      );
    } catch (e) {
      throw Exception('Failed to analyze image from file: ${e.toString()}');
    }
  }

  /// Analyzes an image from bytes with specified MIME type
  static Future<String> analyzeImageFromBytesAndMimeType(
    Uint8List imageBytes,
    String mimeType, {
    String? customPrompt,
  }) async {
    try {
      final String base64Image = base64Encode(imageBytes);
      final prompt =
          customPrompt ??
          'Describe the food in this image clearly and identify any ingredients you can see.';

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'inlineData': {'mimeType': mimeType, 'data': base64Image},
                },
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.4,
            'topK': 32,
            'topP': 1,
            'maxOutputTokens': 4096,
          },
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['candidates'] != null &&
            json['candidates'].isNotEmpty &&
            json['candidates'][0]['content'] != null &&
            json['candidates'][0]['content']['parts'] != null &&
            json['candidates'][0]['content']['parts'].isNotEmpty) {
          return json['candidates'][0]['content']['parts'][0]['text'];
        } else {
          throw Exception('Unexpected response structure: ${response.body}');
        }
      } else {
        throw Exception(
          'API request failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to analyze image from bytes: ${e.toString()}');
    }
  }

  /// Extracts food items with nutrition from an image file
  static Future<List<Map<String, dynamic>>> extractFoodItemsFromImage(
    File imageFile,
  ) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      String mimeType = 'image/jpeg';
      final String extension = imageFile.path.split('.').last.toLowerCase();

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
      return await extractFoodItemsFromBytesAndMimeType(imageBytes, mimeType);
    } catch (e) {
      print('Image nutrition extraction error: ${e.toString()}');
      return [];
    }
  }

  /// Extracts food items with nutrition from image bytes
  static Future<List<Map<String, dynamic>>>
  extractFoodItemsFromBytesAndMimeType(
    Uint8List imageBytes,
    String mimeType,
  ) async {
    try {
      final prompt = '''
Analyze this food image and:
1. Identify all food items
2. Estimate nutritional content for each item, including: calories, protein, carbs, fats, cholesterol, sugar, vitamin A, vitamin D, vitamin C, vitamin E, vitamin B6, vitamin B12, calcium (Ca), magnesium (Mg), potassium (K), iron (Fe), zinc (Zn), saturated fat, fiber, and sodium.
3. Format response as JSON

Use this JSON format:
{
  "foodItems": [
    {
      "name": "food name",
      "quantity": "estimated quantity",
      "calories": number,
      "protein": number,
      "carbs": number,
      "fats": number,
      "cholesterol": number,
      "sugar": number,
      "vitaminA": number,
      "vitaminD": number,
      "vitaminC": number,
      "vitaminE": number,
      "vitaminB6": number,
      "vitaminB12": number,
      "ca": number,
      "mg": number,
      "k": number,
      "fe": number,
      "zn": number,
      "saturatedFat": number,
      "fiber": number,
      "sodium": number
    }
  ]
}
''';

      final response = await analyzeImageFromBytesAndMimeType(
        imageBytes,
        mimeType,
        customPrompt: prompt,
      );
      final cleanedResponse = _cleanJsonResponse(response);
      final jsonData = jsonDecode(cleanedResponse);

      if (jsonData['foodItems'] != null && jsonData['foodItems'] is List) {
        return List<Map<String, dynamic>>.from(jsonData['foodItems']);
      }
      return [];
    } catch (e) {
      throw Exception(
        'Failed to extract food items from bytes: ${e.toString()}',
      );
    }
  }

  /// Helper to clean JSON responses
  static String _cleanJsonResponse(String response) {
    // Remove markdown code fences
    String cleaned =
        response.replaceAll('```json', '').replaceAll('```', '').trim();

    // Find the first '{' and last '}' to extract JSON object
    final jsonStartIndex = cleaned.indexOf('{');
    final jsonEndIndex = cleaned.lastIndexOf('}');

    if (jsonStartIndex != -1 &&
        jsonEndIndex != -1 &&
        jsonEndIndex > jsonStartIndex) {
      cleaned = cleaned.substring(jsonStartIndex, jsonEndIndex + 1);
    }

    // Remove any non-printable characters
    cleaned = cleaned.replaceAll(RegExp(r'[^\x20-\x7E]'), '');

    return cleaned;
  }

  /// Generates a meal plan based on user profile
  static Future<String> generateMealPlan(
    UserProfile profile, {
    bool isWeekly = false,
  }) async {
    try {
      String prompt = _buildMealPlanPrompt(profile, isWeekly);
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 32,
            'topP': 1,
            'maxOutputTokens': 4096,
          },
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['candidates'] != null &&
            json['candidates'].isNotEmpty &&
            json['candidates'][0]['content'] != null &&
            json['candidates'][0]['content']['parts'] != null &&
            json['candidates'][0]['content']['parts'].isNotEmpty) {
          return json['candidates'][0]['content']['parts'][0]['text'];
        } else {
          throw Exception('Unexpected response structure: ${response.body}');
        }
      } else {
        throw Exception(
          'API request failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to generate meal plan: ${e.toString()}');
    }
  }

  /// Builds a prompt for meal plan generation
  static String _buildMealPlanPrompt(UserProfile profile, bool isWeekly) {
    final StringBuilder = StringBuffer();
    StringBuilder.write(
      'Generate a ${isWeekly ? "weekly" : "daily"} personalized meal plan for a ',
    );

    // User characteristics
    if (profile.age != null) StringBuilder.write('${profile.age}-year-old ');
    if (profile.gender != null) StringBuilder.write('${profile.gender} ');
    if (profile.height != null && profile.weight != null) {
      final bmi = (profile.weight! /
              ((profile.height! / 100) * (profile.height! / 100)))
          .toStringAsFixed(1);
      StringBuilder.write('with BMI $bmi. ');
    }

    // Health considerations
    if (profile.healthConditions != null &&
        profile.healthConditions!.isNotEmpty) {
      StringBuilder.write(
        'Health conditions: ${profile.healthConditions!.join(", ")}. ',
      );
    }
    if (profile.dietaryRestrictions != null &&
        profile.dietaryRestrictions!.isNotEmpty) {
      StringBuilder.write(
        'Dietary restrictions: ${profile.dietaryRestrictions!.join(", ")}. ',
      );
    }
    if (profile.dietaryGoals != null && profile.dietaryGoals!.isNotEmpty) {
      StringBuilder.write(
        'Dietary goals: ${profile.dietaryGoals!.join(", ")}. ',
      );
    }

    // Nutritional targets
    if (profile.totalCaloriesGoal != null) {
      StringBuilder.write('Daily calorie goal: ${profile.totalCaloriesGoal}. ');
    }
    if (profile.activityLevel != null) {
      StringBuilder.write('Activity level: ${profile.activityLevel}. ');
    }

    // Tanzanian food focus
    StringBuilder.write(
      'Focus exclusively on Tanzanian and East African foods. Use ingredients like: '
      'ugali (maize flour), wali (rice), mtori (plantain stew), ndizi (plantains), '
      'mchicha (amaranth), sukuma wiki (kale), dagaa (small fish), samaki (fish), '
      'nyama ya ngombe (beef), kuku (chicken), maharage (beans), viazi (potatoes), '
      'muhogo (cassava), ufuta (sesame), nazi (coconut), and tropical fruits. '
      'Include traditional dishes like: '
      'ugali na mchuzi, wali wa nazi, pilau, chapati, mtori, ndizi kaanga, kachumbari, '
      'mchuzi wa samaki, nyama choma, and uji (porridge). '
      'Structure meals with lunch as the main meal. '
      'Ensure all suggestions are culturally appropriate and locally available in Tanzania.',
    );

    // Format instructions
    StringBuilder.write('''
Format response as JSON with structure:
${isWeekly ? '"dailyPlans": [' : ''}
${isWeekly ? '  {' : ''}
  "date": "YYYY-MM-DD",
  "meals": [
    {
      "mealType": "Breakfast/Lunch/Dinner/Snack",
      "foodItems": [
        {
          "foodItem": "Name",
          "foodType": "Category",
          "calories": 0,
          "protein": 0,
          "fats": 0,
          "carbs": 0,
          // ... other nutrients ...
        }
      ],
      "instructions": "Preparation",
      "healthBenefits": "Benefits"
    }
  ]
${isWeekly ? '  }' : ''}
${isWeekly ? ']' : ''}
''');

    return StringBuilder.toString();
  }

  /// Parse the JSON response from Gemini
  static dynamic parseMealPlanResponse(String response, bool isWeekly) {
    try {
      String cleanedResponse = response;
      if (response.contains('```json')) {
        cleanedResponse = response.split('```json')[1].split('```')[0].trim();
      } else if (response.contains('```')) {
        cleanedResponse = response.split('```')[1].split('```')[0].trim();
      }

      if (!cleanedResponse.trim().startsWith('{')) {
        final jsonStartIndex = cleanedResponse.indexOf('{');
        final jsonEndIndex = cleanedResponse.lastIndexOf('}');
        if (jsonStartIndex >= 0 && jsonEndIndex > jsonStartIndex) {
          cleanedResponse = cleanedResponse.substring(
            jsonStartIndex,
            jsonEndIndex + 1,
          );
        }
      }

      Map<String, dynamic> jsonData;
      try {
        jsonData = jsonDecode(cleanedResponse);
      } catch (e) {
        print('Error decoding JSON: ${e.toString()}');
        print('Response: $cleanedResponse');
        return isWeekly
            ? _createDefaultWeeklyPlan()
            : _createDefaultDailyPlan();
      }

      if (isWeekly) {
        if (!jsonData.containsKey('dailyPlans')) {
          if (jsonData.containsKey('meals')) {
            jsonData = {
              'dailyPlans': [jsonData],
            };
          } else {
            return _createDefaultWeeklyPlan();
          }
        }
        return WeeklyMealPlan.fromJson(jsonData);
      } else {
        if (!jsonData.containsKey('meals') && !jsonData.containsKey('date')) {
          List<dynamic> meals = [];
          if (jsonData.containsKey('dailyPlans') &&
              jsonData['dailyPlans'] is List &&
              (jsonData['dailyPlans'] as List).isNotEmpty) {
            var firstPlan = (jsonData['dailyPlans'] as List)[0];
            if (firstPlan is Map<String, dynamic> &&
                firstPlan.containsKey('meals') &&
                firstPlan['meals'] is List) {
              meals = firstPlan['meals'] as List;
            }
          }
          jsonData = {'date': DateTime.now().toIso8601String(), 'meals': meals};
        }
        return DailyMealPlan.fromJson(jsonData);
      }
    } catch (e) {
      print('Failed to parse meal plan response: ${e.toString()}');
      return isWeekly ? _createDefaultWeeklyPlan() : _createDefaultDailyPlan();
    }
  }

  /// Create a default daily meal plan
  static DailyMealPlan _createDefaultDailyPlan() {
    return DailyMealPlan(
      date: DateTime.now(),
      meals: [
        Meal(
          mealType: 'Breakfast',
          foodItems: [],
          instructions: 'Could not generate meal plan. Please try again.',
          healthBenefits: '',
        ),
        Meal(
          mealType: 'Lunch',
          foodItems: [],
          instructions: '',
          healthBenefits: '',
        ),
        Meal(
          mealType: 'Dinner',
          foodItems: [],
          instructions: '',
          healthBenefits: '',
        ),
        Meal(
          mealType: 'Snack',
          foodItems: [],
          instructions: '',
          healthBenefits: '',
        ),
      ],
    );
  }

  /// Create a default weekly meal plan
  static WeeklyMealPlan _createDefaultWeeklyPlan() {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    return WeeklyMealPlan(
      dailyPlans: List.generate(
        7,
        (index) => DailyMealPlan(
          date: weekStart.add(Duration(days: index)),
          meals: [
            Meal(
              mealType: 'Breakfast',
              foodItems: [],
              instructions: index == 0 ? 'Could not generate meal plan' : '',
            ),
            Meal(mealType: 'Lunch', foodItems: []),
            Meal(mealType: 'Dinner', foodItems: []),
            Meal(mealType: 'Snack', foodItems: []),
          ],
        ),
      ),
      generatedFor: 'Error generating meal plan',
    );
  }

  /// Handles nutrition-related chat queries with conversation history
  static Future<String> handleNutritionQuery(
    String query,
    List<Map<String, dynamic>> history, // Added conversation history
  ) async {
    try {
      // Build conversation context from history
      String conversationContext = '';
      for (var entry in history) {
        conversationContext += '${entry['role']}: ${entry['content']}\n';
      }

      final String prompt = '''
You are a nutrition assistant that responds in English and Swahili.
Maintain conversation context:
$conversationContext

When asked about nutrition, food, diet, or health:
1. Determine question language
2. Respond in SAME LANGUAGE
3. Keep responses concise but informative
4. Maintain conversation flow and context
5. Redirect non-nutrition queries

USER QUERY: $query

Respond directly without instructions.
''';

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 32,
            'topP': 1,
            'maxOutputTokens': 2048,
          },
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['candidates'] != null &&
            json['candidates'].isNotEmpty &&
            json['candidates'][0]['content'] != null &&
            json['candidates'][0]['content']['parts'] != null &&
            json['candidates'][0]['content']['parts'].isNotEmpty) {
          return json['candidates'][0]['content']['parts'][0]['text'];
        } else {
          throw Exception('Unexpected response structure: ${response.body}');
        }
      } else {
        throw Exception(
          'API request failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return 'Sorry, I couldn\'t process your question. / Samahani, sikuweza kuchakata swali lako.';
    }
  }

  /// Extracts food items from a text description
  static Future<List<Map<String, dynamic>>> extractFoodItemsFromText(
    String description,
  ) async {
    try {
      final String prompt = '''
You are a nutrition analysis assistant for identifying food items from text in English and Swahili.

TASK:
1. Analyze: "$description"
2. Identify all food items
3. For each, estimate nutritional content
4. Focus on Tanzanian/East African foods
5. Preserve original food names

FORMAT RESPONSE AS JSON:
{
  "language": "english" or "swahili",
  "foodItems": [
    {
      "name": "food item name",
      "quantity": "estimated quantity",
      "calories": number,
      "protein": number,
      "carbs": number,
      "fats": number,
      "cholesterol": number,
      "sugar": number, 
      "vitaminA": number,
      "vitaminD": number,
      "vitaminC": number,
      "vitaminE": number,
      "vitaminB6": number,
      "vitaminB12": number,
      "ca": number,
      "mg": number,
      "k": number,
      "fe": number,
      "zn": number,
      "saturatedFat": number,
      "fiber": number,
      "sodium": number
      
      // ... other nutrients ...
    }
  ]
}
''';

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.2,
            'topK': 32,
            'topP': 1,
            'maxOutputTokens': 2048,
          },
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['candidates'] != null &&
            json['candidates'].isNotEmpty &&
            json['candidates'][0]['content'] != null &&
            json['candidates'][0]['content']['parts'] != null &&
            json['candidates'][0]['content']['parts'].isNotEmpty) {
          String responseText =
              json['candidates'][0]['content']['parts'][0]['text'];
          final cleanedResponse = _cleanJsonResponse(responseText);

          try {
            final parsedJson = jsonDecode(cleanedResponse);
            if (parsedJson.containsKey('foodItems') &&
                parsedJson['foodItems'] is List) {
              return List<Map<String, dynamic>>.from(parsedJson['foodItems']);
            } else {
              return [];
            }
          } catch (e) {
            print('Error parsing food items JSON: ${e.toString()}');
            print('Problematic response: $responseText');
            print('Cleaned response: $cleanedResponse');

            // Fallback for Swahili foods
            if (description.toLowerCase().contains("wali") ||
                description.toLowerCase().contains("nyama") ||
                description.toLowerCase().contains("maharage")) {
              return _createSwahiliFallbackNutrition(description);
            }
            return [];
          }
        }
      }
      return [];
    } catch (e) {
      print('Error extracting food items: ${e.toString()}');
      return [];
    }
  }

  /// Fallback nutrition data for common Swahili foods
  static List<Map<String, dynamic>> _createSwahiliFallbackNutrition(
    String description,
  ) {
    final items = <Map<String, dynamic>>[];

    if (description.toLowerCase().contains("wali")) {
      items.add({
        "name": "Wali (Rice)",
        "quantity": "1 cup",
        "calories": 205,
        "protein": 4.3,
        "carbs": 44.5,
        "fats": 0.4,
        "cholesterol": 0,
        "sugar": 0.1,
        "vitaminA": 0,
        "vitaminD": 0,
        "vitaminC": 0,
        "vitaminE": 0.04,
        "vitaminB6": 0.1,
        "vitaminB12": 0,
        "ca": 19.5,
        "mg": 19,
        "k": 55,
        "fe": 0.4,
        "zn": 0.8,
        "saturatedFat": 0.1,
        "fiber": 0.6,
        "sodium": 1,
      });
    }

    if (description.toLowerCase().contains("nyama")) {
      items.add({
        "name": "Nyama (Meat)",
        "quantity": "100g",
        "calories": 250,
        "protein": 26,
        "carbs": 0,
        "fats": 17,
        "cholesterol": 90,
        "sugar": 0,
        "vitaminA": 0,
        "vitaminD": 0.1,
        "vitaminC": 0,
        "vitaminE": 0.3,
        "vitaminB6": 0.5,
        "vitaminB12": 2.5,
        "ca": 12,
        "mg": 24,
        "k": 380,
        "fe": 2.7,
        "zn": 5.3,
        "saturatedFat": 6.5,
        "fiber": 0,
        "sodium": 70,
      });
    }

    if (description.toLowerCase().contains("maharage")) {
      items.add({
        "name": "Maharage (Beans)",
        "quantity": "1 cup",
        "calories": 225,
        "protein": 15,
        "carbs": 40,
        "fats": 0.9,
        "cholesterol": 0,
        "sugar": 0.6,
        "vitaminA": 0,
        "vitaminD": 0,
        "vitaminC": 2,
        "vitaminE": 0.2,
        "vitaminB6": 0.2,
        "vitaminB12": 0,
        "ca": 46,
        "mg": 60,
        "k": 600,
        "fe": 3.6,
        "zn": 1.4,
        "saturatedFat": 0.1,
        "fiber": 15,
        "sodium": 2,
      });
    }

    return items;
  }
}

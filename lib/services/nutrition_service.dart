import 'dart:convert';
import 'package:http/http.dart' as http;

class NutritionService {
  static const String _apiKey =
      '67875e47d73940058fb4f7712f7bc740'; // <-- Replace with your Spoonacular API key
  static const String _baseUrl = 'https://api.spoonacular.com/';

  // Function to search for food and get nutritional information from Spoonacular
  static Future<String> searchFood(String query) async {
    final url = Uri.parse(
      '$_baseUrl/food/ingredients/search?query=$query&apiKey=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];

      if (results.isNotEmpty) {
        final food = results[0];
        final name = food['name'];
        final id = food['id'];

        // Fetch detailed nutrition information for the ingredient
        final nutritionUrl = Uri.parse(
          '$_baseUrl/food/ingredients/$id/information?apiKey=$_apiKey',
        );

        final nutritionResponse = await http.get(nutritionUrl);

        if (nutritionResponse.statusCode == 200) {
          final nutritionData = json.decode(nutritionResponse.body);
          final calories = nutritionData['calories'];
          final protein = nutritionData['protein'];
          final fat = nutritionData['fat'];
          final carbs = nutritionData['carbs'];

          return '$name contains:\nCalories: $calories kcal\nProtein: $protein g\nFat: $fat g\nCarbs: $carbs g';
        } else {
          return "Error ${nutritionResponse.statusCode}: Unable to fetch detailed nutrition data.";
        }
      } else {
        return "No food found for \"$query\".";
      }
    } else {
      return "Error ${response.statusCode}: Unable to fetch data.";
    }
  }
}

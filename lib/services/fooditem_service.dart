import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/food_item.dart';

class FoodItemService {
  final String apiBaseUrl;

  FoodItemService(this.apiBaseUrl);

  /// Fetch a list of all food items
  Future<List<FoodItem>> fetchFoodItems() async {
    final response = await http.get(Uri.parse(apiBaseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => FoodItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load food items');
    }
  }

  /// Fetch a single food item by its name
  Future<FoodItem> fetchFoodItemByName(String foodName) async {
    final url = '$apiBaseUrl$foodName';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return FoodItem.fromJson(data[0]); // Assuming the response is a list
      } else {
        throw Exception('No data found for $foodName');
      }
    } else {
      throw Exception('Failed to load food item for $foodName');
    }
  }
}

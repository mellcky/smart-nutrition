import 'package:flutter/material.dart';
import '../models/food_item.dart';

class FoodItemProvider with ChangeNotifier {
  final Map<DateTime, List<FoodItem>> _loggedFoodItemsByDate = {};
  FoodItem? _singleLoggedFood;

  List<FoodItem> getFoodItemsForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return _loggedFoodItemsByDate[dateKey] ?? [];
  }

  List<FoodItem> getFoodItemsForDateRange(DateTime start, DateTime end) {
    final items = <FoodItem>[];
    var current = start;

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      items.addAll(getFoodItemsForDate(current));
      current = current.add(const Duration(days: 1));
    }

    return items;
  }

  void logFoodItem(FoodItem foodItem) {
    final dateKey = DateTime(
      foodItem.timestamp.year,
      foodItem.timestamp.month,
      foodItem.timestamp.day,
    );

    if (!_loggedFoodItemsByDate.containsKey(dateKey)) {
      _loggedFoodItemsByDate[dateKey] = [];
    }

    _loggedFoodItemsByDate[dateKey]!.add(foodItem);
    _singleLoggedFood = foodItem;
    notifyListeners();
  }

  void clearLoggedFood() {
    _singleLoggedFood = null;
    notifyListeners();
  }

  void addFoodItemsForDate(DateTime date, List<FoodItem> items) {
    final dateKey = DateTime(date.year, date.month, date.day);
    _loggedFoodItemsByDate[dateKey] = items;
    notifyListeners();
  }

  void clearFoodItemsForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    _loggedFoodItemsByDate.remove(dateKey);
    notifyListeners();
  }

  double getTotalCalories(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.calories);

  double getTotalProtein(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.protein);

  double getTotalCarbs(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.carbs);

  double getTotalFats(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.fats);

  // Other nutrient getters remain the same
  double getTotalFiber(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.fiber);
  double getTotalSodium(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.sodium);
  double getTotalCholesterol(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.chorestrol);
  double getTotalSugar(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.sugar);
  double getTotalVitaminA(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.vitaminA);
  double getTotalVitaminC(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.vitaminC);
  double getTotalVitaminD(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.vitaminD);
  double getTotalVitaminE(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.vitaminE);
  double getTotalVitaminB6(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.vitaminB6);
  double getTotalVitaminB12(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.vitaminB12);
  double getTotalCalcium(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.ca);
  double getTotalMagnesium(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.mg);
  double getTotalPotassium(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.k);
  double getTotalIron(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.fe);
  double getTotalZinc(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.zn);
  double getTotalSaturatedFat(DateTime date) =>
      getFoodItemsForDate(date).fold(0, (sum, item) => sum + item.saturatedFat);
  double getTotalFoodItems(DateTime date) =>
      getFoodItemsForDate(date).length.toDouble();
}

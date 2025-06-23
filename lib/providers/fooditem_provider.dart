import 'package:flutter/material.dart';
import '../models/food_item.dart';

class FoodItemProvider with ChangeNotifier {
  List<FoodItem> _loggedFoodItems = [];
  FoodItem? _singleLoggedFood; // For temporary storage

  List<FoodItem> get loggedFoodItems => _loggedFoodItems;
  FoodItem? get loggedFood => _singleLoggedFood;

  void logFoodItem(FoodItem foodItem) {
    _loggedFoodItems.add(foodItem);
    _singleLoggedFood = foodItem; // Store for immediate display
    notifyListeners();
  }

  void clearLoggedFood() {
    _singleLoggedFood = null;
    notifyListeners();
  }

  // For daily totals
  double get totalCalories =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.calories);
  double get totalProtein =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.protein);
  double get totalCarbs =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.carbs);
  double get totalFats =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.fats);

  double get totalFiber =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.fiber);
  double get totalSodium =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.sodium);
  double get totalCholesterol =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.chorestrol);
  double get totalSugar =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.sugar);
  double get totalVitaminA =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.vitaminA);
  double get totalVitaminC =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.vitaminC);
  double get totalVitaminD =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.vitaminD);
  double get totalVitaminE =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.vitaminE);
  double get totalVitaminB6 =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.vitaminB6);
  double get totalVitaminB12 =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.vitaminB12);
  double get totalCalcium =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.ca);
  double get totalMagnesium =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.mg);
  double get totalPotassium =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.k);
  double get totalIron =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.fe);
  double get totalZinc =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.zn);
  double get totalSaturatedFat =>
      _loggedFoodItems.fold(0, (sum, item) => sum + item.saturatedFat);
  double get totalFoodItems => _loggedFoodItems.length.toDouble();

  // Add similar getters for other nutrients...
}

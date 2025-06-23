import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '/db/user_database_helper.dart';
import '/utils/calorie_calculator.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _profileUpdated = false;

  UserProfile? get profile => _profile;
  bool get isLoaded => _profile != null;
  bool get profileUpdated => _profileUpdated;

  final UserDatabaseHelper _dbHelper = UserDatabaseHelper();

  Future<void> loadUserProfile() async {
    try {
      final users = await _dbHelper.getUsers();
      if (users.isNotEmpty) {
        _profile = users.first;
      } else {
        _profile = UserProfile();
      }
      _profileUpdated = false;
      notifyListeners();
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> saveUserProfile() async {
    if (_profile == null) return;

    try {
      if (_profile!.id == null) {
        int id = await _dbHelper.insertUser(_profile!);
        _profile!.id = id;
      } else {
        await _dbHelper.updateUser(_profile!);
      }
      _profileUpdated = true;
      notifyListeners();
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }

  // Getters
  String? get gender => _profile?.gender;
  int? get age => _profile?.age;
  double? get height => _profile?.height;
  double? get weight => _profile?.weight;
  String? get activityLevel => _profile?.activityLevel;
  List<String> get dietaryRestrictions => _profile?.dietaryRestrictions ?? [];
  List<String> get healthConditions => _profile?.healthConditions ?? [];
  List<String> get dietaryGoals => _profile?.dietaryGoals ?? [];
  String? get name => _profile?.name;
  double? get calorieGoal => _profile?.totalCaloriesGoal;

  // Update Methods
  void updateGender(String gender) {
    _profile ??= UserProfile();
    _profile!.gender = gender;
    _profileUpdated = true;
    notifyListeners();
  }

  void updateAge(int age) {
    _profile ??= UserProfile();
    _profile!.age = age;
    _profileUpdated = true;
    notifyListeners();
  }

  void updateHeight(double height) {
    _profile ??= UserProfile();
    _profile!.height = height;
    _profileUpdated = true;
    notifyListeners();
  }

  void updateWeight(double weight) {
    _profile ??= UserProfile();
    _profile!.weight = weight;
    _profileUpdated = true;
    notifyListeners();
  }

  void updateActivityLevel(String activityLevel) {
    _profile ??= UserProfile();
    _profile!.activityLevel = activityLevel;
    _profileUpdated = true;
    notifyListeners();
  }

  void updateDietRestrictions(List<String> restrictions) {
    _profile ??= UserProfile();
    _profile!.dietaryRestrictions = restrictions;
    _profileUpdated = true;
    notifyListeners();
  }

  void updateHealthConditions(List<String> conditions) {
    _profile ??= UserProfile();
    _profile!.healthConditions = conditions;
    _profileUpdated = true;
    notifyListeners();
  }

  void setDietaryGoals(List<String> goals) {
    _profile ??= UserProfile();
    _profile!.dietaryGoals = goals;
    _profileUpdated = true;
    notifyListeners();
  }

  void updateName(String name) {
    _profile ??= UserProfile();
    _profile!.name = name;
    _profileUpdated = true;
    notifyListeners();
  }

  /// 👇 New Method: Calculate and store calorie goal
  Future<void> updateCalorieGoal() async {
    if (_profile == null) return;

    try {
      final calculatedGoal = calculateTotalCalories(
        gender: _profile!.gender ?? "",
        age: _profile!.age ?? 0,
        heightCm: _profile!.height ?? 0.0,
        weightKg: _profile!.weight ?? 0.0,
        activityLevel: _profile!.activityLevel ?? "Low",
      );

      _profile!.totalCaloriesGoal = calculatedGoal;
      _profileUpdated = true;
      await saveUserProfile(); // Save updated goal to DB
    } catch (e) {
      print("Error updating calorie goal: $e");
    }
    notifyListeners();
  }

  void resetUpdateFlag() {
    _profileUpdated = false;
  }
}

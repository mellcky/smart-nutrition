import 'package:flutter/material.dart';
import '/models/user_profile.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfile _profile = UserProfile();

  UserProfile get profile => _profile;

  // Getters for easy access
  String? get gender => _profile.gender;
  int? get age => _profile.age;
  double? get height => _profile.height;
  double? get weight => _profile.weight;
  String? get activityLevel => _profile.activityLevel;
  List<String> get dietaryRestrictions => _profile.dietaryRestrictions ?? [];

  // String? get otherDietaryRestrictions => _profile.otherDietaryRestrictions ?? [];
  List<String> get healthConditions => _profile.healthConditions ?? [];
  // String? get otherHealthConditions => _profile.otherHealthConditions ?? [];

  void updateGender(String gender) {
    _profile.gender = gender;
    notifyListeners();
  }

  void updateAge(int age) {
    _profile.age = age;
    notifyListeners();
  }

  void updateHeight(double height) {
    _profile.height = height;
    notifyListeners();
  }

  void updateWeight(double weight) {
    _profile.weight = weight;
    notifyListeners();
  }

  void updateActivityLevel(String activityLevel) {
    _profile.activityLevel = activityLevel;
    notifyListeners(); // Notify listeners when the value changes
  }

  void updateDietRestrictions(List<String> restrictions) {
    _profile.dietaryRestrictions = restrictions;
    notifyListeners();
  }

  void updateHealthConditions(List<String> conditions) {
    _profile.healthConditions = conditions;
    notifyListeners();
  }
}

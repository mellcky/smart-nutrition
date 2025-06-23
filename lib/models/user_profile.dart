import 'dart:convert';

class UserProfile {
  int? id; // for database use
  String? gender;
  int? age;
  double? height;
  double? weight;
  List<String>? healthConditions;
  List<String>? dietaryRestrictions;
  String? activityLevel;
  List<String>? dietaryGoals;
  String? name;
  double? totalCaloriesGoal;

  UserProfile({
    this.id,
    this.gender,
    this.age,
    this.height,
    this.weight,
    this.healthConditions,
    this.dietaryRestrictions,
    this.activityLevel,
    this.dietaryGoals,
    this.name,
    this.totalCaloriesGoal,
  });

  // Convert object to map for insertion into database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'healthConditions': jsonEncode(healthConditions ?? []),
      'dietaryRestrictions': jsonEncode(dietaryRestrictions ?? []),
      'activityLevel': activityLevel,
      'dietaryGoals': jsonEncode(dietaryGoals ?? []),
      'name': name,
      'totalCaloriesGoal': totalCaloriesGoal,
    };
  }

  // Convert database map back to object
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      gender: map['gender'],
      age: map['age'],
      height: map['height']?.toDouble(),
      weight: map['weight']?.toDouble(),
      healthConditions: List<String>.from(jsonDecode(map['healthConditions'])),
      dietaryRestrictions: List<String>.from(
        jsonDecode(map['dietaryRestrictions']),
      ),
      activityLevel: map['activityLevel'],
      dietaryGoals: List<String>.from(jsonDecode(map['dietaryGoals'])),
      name: map['name'],
      totalCaloriesGoal: map['totalCaloriesGoal']?.toDouble(),
    );
  }
}

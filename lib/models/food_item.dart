class FoodItem {
  final String foodItem;
  final double calories;
  final double protein;
  final double fats;
  final double carbs;
  final double chorestrol;
  final double sugar;
  final double vitaminA;
  final double vitaminD;
  final double vitaminC;
  final double vitaminE;
  final double vitaminB6;
  final double vitaminB12;
  final double ca;
  final double mg;
  final double k;
  final double fe;
  final double zn;
  final double saturatedFat;
  final double fiber;
  final double sodium;
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  final DateTime timestamp;

  FoodItem({
    required this.foodItem,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
    required this.chorestrol,
    required this.sugar,
    required this.vitaminA,
    required this.vitaminD,
    required this.vitaminC,
    required this.vitaminE,
    required this.vitaminB6,
    required this.vitaminB12,
    required this.ca,
    required this.mg,
    required this.k,
    required this.fe,
    required this.zn,
    required this.saturatedFat,
    required this.fiber,
    required this.sodium,
    required this.mealType,
    required this.timestamp,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      foodItem: json['foodItem'],
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      fats: (json['fats'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      chorestrol: (json['chorestrol'] ?? 0).toDouble(),
      sugar: (json['sugar'] ?? 0).toDouble(),
      vitaminA: (json['vitaminA'] ?? 0).toDouble(),
      vitaminD: (json['vitaminD'] ?? 0).toDouble(),
      vitaminC: (json['vitaminC'] ?? 0).toDouble(),
      vitaminE: (json['vitaminE'] ?? 0).toDouble(),
      vitaminB6: (json['vitaminB6'] ?? 0).toDouble(),
      vitaminB12: (json['vitaminB12'] ?? 0).toDouble(),
      ca: (json['ca'] ?? 0).toDouble(),
      mg: (json['mg'] ?? 0).toDouble(),
      k: (json['k'] ?? 0).toDouble(),
      fe: (json['fe'] ?? 0).toDouble(),
      zn: (json['zn'] ?? 0).toDouble(),
      saturatedFat: (json['saturatedFat'] ?? 0).toDouble(),
      fiber: (json['fiber'] ?? 0).toDouble(),
      sodium: (json['sodium'] ?? 0).toDouble(),
      mealType: json['mealType'] ?? '',
      timestamp:
          json['timestamp'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodItem': foodItem,
      'calories': calories,
      'protein': protein,
      'fats': fats,
      'carbs': carbs,
      'chorestrol': chorestrol,
      'sugar': sugar,
      'vitaminA': vitaminA,
      'vitaminD': vitaminD,
      'vitaminC': vitaminC,
      'vitaminE': vitaminE,
      'vitaminB6': vitaminB6,
      'vitaminB12': vitaminB12,
      'ca': ca,
      'mg': mg,
      'k': k,
      'fe': fe,
      'zn': zn,
      'saturatedFat': saturatedFat,
      'fiber': fiber,
      'sodium': sodium,
      'mealType': mealType,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      foodItem: map['foodItem'],
      calories: (map['calories'] ?? 0).toDouble(),
      protein: (map['protein'] ?? 0).toDouble(),
      fats: (map['fats'] ?? 0).toDouble(),
      carbs: (map['carbs'] ?? 0).toDouble(),
      chorestrol: (map['chorestrol'] ?? 0).toDouble(),
      sugar: (map['sugar'] ?? 0).toDouble(),
      vitaminA: (map['vitaminA'] ?? 0).toDouble(),
      vitaminD: (map['vitaminD'] ?? 0).toDouble(),
      vitaminC: (map['vitaminC'] ?? 0).toDouble(),
      vitaminE: (map['vitaminE'] ?? 0).toDouble(),
      vitaminB6: (map['vitaminB6'] ?? 0).toDouble(),
      vitaminB12: (map['vitaminB12'] ?? 0).toDouble(),
      ca: (map['ca'] ?? 0).toDouble(),
      mg: (map['mg'] ?? 0).toDouble(),
      k: (map['k'] ?? 0).toDouble(),
      fe: (map['fe'] ?? 0).toDouble(),
      zn: (map['zn'] ?? 0).toDouble(),
      saturatedFat: (map['saturatedFat'] ?? 0).toDouble(),
      fiber: (map['fiber'] ?? 0).toDouble(),
      sodium: (map['sodium'] ?? 0).toDouble(),
      mealType: map['mealType'] ?? '',
      timestamp:
          map['timestamp'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
              : DateTime.now(),
    );
  }
}

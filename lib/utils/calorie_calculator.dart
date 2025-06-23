double calculateTotalCalories({
  required String gender,
  required int age,
  required double heightCm,
  required double weightKg,
  required String activityLevel,
}) {
  double bmr;

  // Mifflin-St Jeor Equation
  if (gender.toLowerCase() == 'male') {
    bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
  } else {
    bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
  }

  double multiplier;

  switch (activityLevel.toLowerCase()) {
    case 'sedentary':
      multiplier = 1.2;
      break;
    case 'light':
      multiplier = 1.375;
      break;
    case 'moderate':
      multiplier = 1.55;
      break;
    case 'active':
      multiplier = 1.725;
      break;
    case 'very active':
      multiplier = 1.9;
      break;
    default:
      multiplier = 1.2; // fallback
  }

  return (bmr * multiplier).roundToDouble(); // Rounded result
}

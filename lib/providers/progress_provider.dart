import 'package:flutter/material.dart';

class ProgressProvider with ChangeNotifier {
  int _currentStep = 1; // Start at step 1

  int get currentStep => _currentStep;
  int get totalSteps => 7; // Total number of steps

  void nextStep() {
    if (_currentStep < totalSteps) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 1) {
      _currentStep--;
      notifyListeners();
    }
  }

  double get progress => _currentStep / totalSteps; // Calculate the progress
}

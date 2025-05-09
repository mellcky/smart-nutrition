import 'package:flutter/material.dart';

class ProgressProvider with ChangeNotifier {
  double _progress = 0.0;

  double get progress => _progress;

  void setProgress(double value) {
    _progress = value.clamp(0.0, 1.0); // Ensure it's between 0 and 1
    notifyListeners();
  }
}

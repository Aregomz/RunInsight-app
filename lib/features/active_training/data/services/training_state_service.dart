// features/active_training/data/services/training_state_service.dart
import 'package:flutter/foundation.dart';

class TrainingStateService extends ChangeNotifier {
  static final TrainingStateService _instance = TrainingStateService._internal();
  factory TrainingStateService() => _instance;
  TrainingStateService._internal();

  bool _isTrainingActive = false;

  bool get isTrainingActive => _isTrainingActive;

  void setTrainingActive(bool active) {
    _isTrainingActive = active;
    notifyListeners();
    if (kDebugMode) {
      print('🏃 TrainingStateService - Training active: $_isTrainingActive');
    }
  }

  void startTraining() {
    setTrainingActive(true);
  }

  void stopTraining() {
    setTrainingActive(false);
  }
} 
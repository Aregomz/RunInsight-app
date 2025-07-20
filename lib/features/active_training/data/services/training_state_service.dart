// features/active_training/data/services/training_state_service.dart
import 'package:flutter/foundation.dart';

class TrainingStateService extends ChangeNotifier {
  static final TrainingStateService _instance = TrainingStateService._internal();
  factory TrainingStateService() => _instance;
  TrainingStateService._internal();

  bool _isTrainingActive = false;
  bool _isDisposed = false;

  bool get isTrainingActive {
    if (_isDisposed) {
      if (kDebugMode) {
        print('⚠️ TrainingStateService - Intentando leer después de ser eliminado');
      }
      return false;
    }
    return _isTrainingActive;
  }

  void setTrainingActive(bool active) {
    if (_isDisposed) {
      if (kDebugMode) {
        print('⚠️ TrainingStateService - Intentando usar después de ser eliminado');
      }
      return;
    }
    
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

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // Método para resetear el estado (útil para logout)
  void reset() {
    _isTrainingActive = false;
    _isDisposed = false;
    if (kDebugMode) {
      print('🔄 TrainingStateService - Estado reseteado');
    }
  }
} 
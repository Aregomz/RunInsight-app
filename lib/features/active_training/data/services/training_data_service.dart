class TrainingDataService {
  static Map<String, dynamic>? _lastTrainingData;

  static void setLastTrainingData(Map<String, dynamic> data) {
    _lastTrainingData = data;
  }

  static Map<String, dynamic>? getLastTrainingData() {
    return _lastTrainingData;
  }

  static void clearLastTrainingData() {
    _lastTrainingData = null;
  }
} 
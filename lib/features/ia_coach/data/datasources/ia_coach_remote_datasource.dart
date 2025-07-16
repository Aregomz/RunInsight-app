import '../models/ia_prediction_model.dart';

abstract class IaCoachRemoteDatasource {
  Future<List<IaPredictionModel>> getPredictions({
    required Map<String, dynamic> userStats,
    required List<Map<String, dynamic>> lastTrainings,
  });
} 
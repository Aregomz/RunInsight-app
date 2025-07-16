import '../entities/ia_prediction_entity.dart';

abstract class IaCoachRepository {
  Future<List<IaPredictionEntity>> getPredictions({
    required Map<String, dynamic> userStats,
    required List<Map<String, dynamic>> lastTrainings,
  });
} 
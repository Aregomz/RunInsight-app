import '../entities/ia_prediction_entity.dart';
import '../repositories/ia_coach_repository.dart';

class GetIaPredictionsUseCase {
  final IaCoachRepository repository;
  GetIaPredictionsUseCase(this.repository);

  Future<List<IaPredictionEntity>> call({
    required Map<String, dynamic> userStats,
    required List<Map<String, dynamic>> lastTrainings,
  }) async {
    return await repository.getPredictions(
      userStats: userStats,
      lastTrainings: lastTrainings,
    );
  }
} 
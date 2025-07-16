import '../../domain/entities/ia_prediction_entity.dart';
import '../../domain/repositories/ia_coach_repository.dart';
import '../datasources/ia_coach_remote_datasource.dart';

class IaCoachRepositoryImpl implements IaCoachRepository {
  final IaCoachRemoteDatasource remoteDatasource;
  IaCoachRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<IaPredictionEntity>> getPredictions({
    required Map<String, dynamic> userStats,
    required List<Map<String, dynamic>> lastTrainings,
  }) async {
    return await remoteDatasource.getPredictions(
      userStats: userStats,
      lastTrainings: lastTrainings,
    );
  }
} 
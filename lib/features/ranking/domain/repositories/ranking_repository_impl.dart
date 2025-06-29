// features/ranking/data/repositories/ranking_repository_impl.dart
import 'package:runinsight/features/ranking/domain/entities/ranking_user_entity.dart';
import 'package:runinsight/features/ranking/domain/repositories/ranking_repository.dart';

class RankingRepositoryImpl implements RankingRepository {
  @override
  Future<List<RankingUserEntity>> getRanking(String userId) async {
    // Simulación de datos locales (para pruebas sin backend)
    await Future.delayed(const Duration(milliseconds: 500)); // Simula carga

    final simulated = [
      RankingUserEntity(id: '1', name: 'Marco', totalKm: 35.0, trainings: 4),
      RankingUserEntity(id: '2', name: 'Laura', totalKm: 45.0, trainings: 6),
      RankingUserEntity(id: '3', name: 'Carlos', totalKm: 40.0, trainings: 3),
      RankingUserEntity(id: '4', name: 'Ana', totalKm: 25.0, trainings: 2),
      RankingUserEntity(id: '5', name: 'Sofía', totalKm: 30.0, trainings: 3),
      RankingUserEntity(id: userId, name: 'Tú', totalKm: 20.0, trainings: 2),
    ];

    // Ordenar por promedio y luego por número de entrenamientos (desempate)
    simulated.sort((a, b) {
      final aRatio = a.avgKmPerTraining;
      final bRatio = b.avgKmPerTraining;
      if (bRatio != aRatio) {
        return bRatio.compareTo(aRatio);
      } else {
        return b.trainings.compareTo(a.trainings);
      }
    });

    return simulated;

    // TODO: Conexión futura con backend
    // final response = await http.get(...);
    // return response.map(...);
  }
}
// features/home/data/repositories/weekly_stats_repository_impl.dart
import '../../domain/entities/weekly_stats_entity.dart';
import '../../domain/repositories/weekly_stats_repository.dart';
import '../datasources/weekly_stats_remote_datasource.dart';

class WeeklyStatsRepositoryImpl implements WeeklyStatsRepository {
  final WeeklyStatsRemoteDataSource remoteDataSource;

  WeeklyStatsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<WeeklyStatsEntity> getWeeklyStats(int userId) async {
    try {
      print('🔄 Obteniendo estadísticas semanales del usuario $userId desde el repositorio');
      
      final response = await remoteDataSource.getWeeklyStats(userId);
      
      final stats = WeeklyStatsEntity(
        totalKm: response.totalKm,
        totalTrainings: response.totalTrainings,
        avgRhythm: response.avgRhythm,
      );

      print('✅ Estadísticas semanales obtenidas exitosamente: ${stats.totalKm}km, ${stats.avgRhythm}min/km');
      return stats;
    } catch (e) {
      print('❌ Error en el repositorio al obtener estadísticas semanales: $e');
      throw Exception('Error al obtener estadísticas semanales: $e');
    }
  }
} 
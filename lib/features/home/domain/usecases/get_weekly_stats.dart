// features/home/domain/usecases/get_weekly_stats.dart
import '../entities/weekly_stats_entity.dart';
import '../repositories/weekly_stats_repository.dart';

class GetWeeklyStats {
  final WeeklyStatsRepository repository;

  GetWeeklyStats(this.repository);

  Future<WeeklyStatsEntity> call(int userId) async {
    return await repository.getWeeklyStats(userId);
  }
} 
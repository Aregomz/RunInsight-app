// features/home/domain/repositories/weekly_stats_repository.dart
import '../entities/weekly_stats_entity.dart';

abstract class WeeklyStatsRepository {
  Future<WeeklyStatsEntity> getWeeklyStats(int userId);
} 
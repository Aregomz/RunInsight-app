// features/home/domain/entities/weekly_stats_entity.dart
class WeeklyStatsEntity {
  final double totalKm;
  final int totalTrainings;
  final double avgRhythm;

  WeeklyStatsEntity({
    required this.totalKm,
    required this.totalTrainings,
    required this.avgRhythm,
  });
} 
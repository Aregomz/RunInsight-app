// features/home/data/models/weekly_stats_response_model.dart
class WeeklyStatsResponseModel {
  final String message;
  final double totalKm;
  final int totalTrainings;
  final double avgRhythm;
  final bool success;

  WeeklyStatsResponseModel({
    required this.message,
    required this.totalKm,
    required this.totalTrainings,
    required this.avgRhythm,
    required this.success,
  });

  factory WeeklyStatsResponseModel.fromJson(Map<String, dynamic> json) {
    return WeeklyStatsResponseModel(
      message: json['message'] ?? '',
      totalKm: (json['totalKm'] ?? 0.0).toDouble(),
      totalTrainings: json['totalTrainings'] ?? 0,
      avgRhythm: (json['avgRhythm'] ?? 0.0).toDouble(),
      success: json['success'] ?? false,
    );
  }
} 
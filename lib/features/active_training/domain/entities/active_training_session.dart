// features/active_training/domain/entities/active_training_session.dart

class ActiveTrainingSession {
  final DateTime startTime;
  final DateTime? endTime;
  final double distanceKm;
  final Duration duration;
  final double pace;
  final int avgHeartRate;
  final int caloriesBurned;

  ActiveTrainingSession({
    required this.startTime,
    this.endTime,
    required this.distanceKm,
    required this.duration,
    required this.pace,
    required this.avgHeartRate,
    required this.caloriesBurned,
  });

  ActiveTrainingSession copyWith({
    DateTime? startTime,
    DateTime? endTime,
    double? distanceKm,
    Duration? duration,
    double? pace,
    int? avgHeartRate,
    int? caloriesBurned,
  }) {
    return ActiveTrainingSession(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distanceKm: distanceKm ?? this.distanceKm,
      duration: duration ?? this.duration,
      pace: pace ?? this.pace,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    );
  }

  static ActiveTrainingSession empty() {
    return ActiveTrainingSession(
      startTime: DateTime.now(),
      endTime: null,
      distanceKm: 0.0,
      duration: Duration.zero,
      pace: 0.0,
      avgHeartRate: 0,
      caloriesBurned: 0,
    );
  }
}
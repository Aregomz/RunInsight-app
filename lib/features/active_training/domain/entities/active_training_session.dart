// features/active_training/domain/entities/active_training_session.dart

class ActiveTrainingSession {
  final int timeMinutes;
  final double distanceKm;
  final double rhythm;
  final String date;
  final double altitude;
  final String? notes;
  final String trainingType;
  final String terrainType;
  final String weather;

  ActiveTrainingSession({
    required this.timeMinutes,
    required this.distanceKm,
    required this.rhythm,
    required this.date,
    required this.altitude,
    this.notes,
    required this.trainingType,
    required this.terrainType,
    required this.weather,
  });
}
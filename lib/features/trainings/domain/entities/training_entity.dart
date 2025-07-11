// features/trainings/domain/entities/training_entity.dart
class TrainingEntity {
  final int id;
  final int timeMinutes;
  final double distanceKm;
  final double rhythm;
  final DateTime date;
  final double altitude;
  final String? notes;
  final String trainingType;
  final String terrainType;
  final String weather;

  TrainingEntity({
    required this.id,
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
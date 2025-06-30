// features/trainings/domain/entities/training_entity.dart
class TrainingEntity {
  final String id;
  final DateTime date;
  final double kilometers;
  final String pace; // ritmo
  final String duration; // duración total (ej: "45:30")
  final String time; // hora del día
  final String weather; // clima del día
  final int heartRate; // frecuencia cardíaca promedio
  final int calories;

  TrainingEntity({
    required this.id,
    required this.date,
    required this.kilometers,
    required this.pace,
    required this.duration,
    required this.time,
    required this.weather,
    required this.heartRate,
    required this.calories,
  });
}
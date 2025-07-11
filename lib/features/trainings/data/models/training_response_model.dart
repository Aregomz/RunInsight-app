// features/trainings/data/models/training_response_model.dart
class TrainingResponseModel {
  final String message;
  final List<TrainingModel> trainings;
  final bool success;

  TrainingResponseModel({
    required this.message,
    required this.trainings,
    required this.success,
  });

  factory TrainingResponseModel.fromJson(Map<String, dynamic> json) {
    return TrainingResponseModel(
      message: json['message'] ?? '',
      trainings: (json['trainings'] as List<dynamic>?)
          ?.map((training) => TrainingModel.fromJson(training))
          .toList() ?? [],
      success: json['success'] ?? false,
    );
  }
}

class TrainingModel {
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

  TrainingModel({
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

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id'] ?? 0,
      timeMinutes: json['time_minutes'] ?? 0,
      distanceKm: (json['distance_km'] ?? 0.0).toDouble(),
      rhythm: (json['rhythm'] ?? 0.0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      altitude: (json['altitude'] ?? 0.0).toDouble(),
      notes: json['notes'],
      trainingType: json['trainingType'] ?? '',
      terrainType: json['terrainType'] ?? '',
      weather: json['weather'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time_minutes': timeMinutes,
      'distance_km': distanceKm,
      'rhythm': rhythm,
      'date': date.toIso8601String(),
      'altitude': altitude,
      'notes': notes,
      'trainingType': trainingType,
      'terrainType': terrainType,
      'weather': weather,
    };
  }
} 
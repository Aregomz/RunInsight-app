import 'package:equatable/equatable.dart';
import '../../domain/entities/active_training_session.dart';

abstract class ActiveTrainingEvent extends Equatable {
  const ActiveTrainingEvent();
  @override
  List<Object?> get props => [];
}

class StartTraining extends ActiveTrainingEvent {}

class UpdateTrainingData extends ActiveTrainingEvent {
  final int timeMinutes;
  final double distanceKm;
  final double rhythm;
  final double altitude;
  final String weather;

  const UpdateTrainingData({
    required this.timeMinutes,
    required this.distanceKm,
    required this.rhythm,
    required this.altitude,
    required this.weather,
  });

  @override
  List<Object?> get props => [timeMinutes, distanceKm, rhythm, altitude, weather];
}

class FinishTraining extends ActiveTrainingEvent {
  final String trainingType;
  final String terrainType;
  final String? notes;
  final int? realTimeMinutes;

  const FinishTraining({
    required this.trainingType,
    required this.terrainType,
    this.notes,
    this.realTimeMinutes,
  });

  @override
  List<Object?> get props => [trainingType, terrainType, notes, realTimeMinutes];
}

class ResetTraining extends ActiveTrainingEvent {}
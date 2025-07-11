import 'package:equatable/equatable.dart';
import '../../domain/entities/active_training_session.dart';

abstract class ActiveTrainingState extends Equatable {
  const ActiveTrainingState();
  @override
  List<Object?> get props => [];
}

class ActiveTrainingInitial extends ActiveTrainingState {}

class ActiveTrainingInProgress extends ActiveTrainingState {
  final int timeMinutes;
  final double distanceKm;
  final double rhythm;
  final double altitude;
  final String weather;

  const ActiveTrainingInProgress({
    required this.timeMinutes,
    required this.distanceKm,
    required this.rhythm,
    required this.altitude,
    required this.weather,
  });

  @override
  List<Object?> get props => [timeMinutes, distanceKm, rhythm, altitude, weather];
}

class ActiveTrainingReadyToFinish extends ActiveTrainingState {
  final int timeMinutes;
  final double distanceKm;
  final double rhythm;
  final double altitude;
  final String weather;

  const ActiveTrainingReadyToFinish({
    required this.timeMinutes,
    required this.distanceKm,
    required this.rhythm,
    required this.altitude,
    required this.weather,
  });

  @override
  List<Object?> get props => [timeMinutes, distanceKm, rhythm, altitude, weather];
}

class ActiveTrainingSaving extends ActiveTrainingState {}

class ActiveTrainingSuccess extends ActiveTrainingState {
  final int timeMinutes;
  final double distanceKm;
  final double rhythm;
  final double altitude;
  final String weather;
  final String trainingType;
  final String terrainType;
  final String? notes;
  final String date;

  const ActiveTrainingSuccess({
    required this.timeMinutes,
    required this.distanceKm,
    required this.rhythm,
    required this.altitude,
    required this.weather,
    required this.trainingType,
    required this.terrainType,
    this.notes,
    required this.date,
  });

  @override
  List<Object?> get props => [timeMinutes, distanceKm, rhythm, altitude, weather, trainingType, terrainType, notes, date];
}

class ActiveTrainingFailure extends ActiveTrainingState {
  final String message;
  const ActiveTrainingFailure(this.message);
  @override
  List<Object?> get props => [message];
}
part of 'trainings_bloc.dart';

abstract class TrainingsState {}

class TrainingsInitial extends TrainingsState {}

class TrainingsLoading extends TrainingsState {}

class TrainingsLoaded extends TrainingsState {
  final List<TrainingEntity> trainings;

  TrainingsLoaded({required this.trainings});
}

class TrainingsError extends TrainingsState {
  final String message;

  TrainingsError(this.message);
}

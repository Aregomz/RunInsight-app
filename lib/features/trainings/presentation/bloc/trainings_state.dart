import 'package:equatable/equatable.dart';
import '../../domain/entities/training_entity.dart';

abstract class TrainingsState extends Equatable {
  const TrainingsState();

  @override
  List<Object> get props => [];
}

class TrainingsInitial extends TrainingsState {}

class TrainingsLoading extends TrainingsState {}

class TrainingsLoaded extends TrainingsState {
  final List<TrainingEntity> trainings;

  const TrainingsLoaded({required this.trainings});

  @override
  List<Object> get props => [trainings];
}

class TrainingsError extends TrainingsState {
  final String message;

  const TrainingsError({required this.message});

  @override
  List<Object> get props => [message];
}

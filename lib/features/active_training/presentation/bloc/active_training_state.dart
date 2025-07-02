// features/active_training/presentation/bloc/active_training_state.dart
part of 'active_training_bloc.dart';

abstract class ActiveTrainingState {}

class ActiveTrainingInitial extends ActiveTrainingState {}

class ActiveTrainingLoading extends ActiveTrainingState {}

class ActiveTrainingInProgress extends ActiveTrainingState {
  final ActiveTrainingSession session;

  ActiveTrainingInProgress({required this.session});
}

class ActiveTrainingCompleted extends ActiveTrainingState {
  final ActiveTrainingSession summary;

  ActiveTrainingCompleted({required this.summary});
}

class ActiveTrainingError extends ActiveTrainingState {
  final String message;

  ActiveTrainingError(this.message);
}
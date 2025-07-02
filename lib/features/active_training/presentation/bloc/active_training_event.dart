// features/active_training/presentation/bloc/active_training_event.dart
part of 'active_training_bloc.dart';

abstract class ActiveTrainingEvent {}

class StartTrainingRequested extends ActiveTrainingEvent {}

class UpdateMetricsRequested extends ActiveTrainingEvent {
  final ActiveTrainingSession session;

  UpdateMetricsRequested(this.session);
}

class FinishTrainingRequested extends ActiveTrainingEvent {}

class GetTrainingSummaryRequested extends ActiveTrainingEvent {}
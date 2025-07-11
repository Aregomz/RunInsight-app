import 'package:equatable/equatable.dart';

abstract class TrainingsEvent extends Equatable {
  const TrainingsEvent();

  @override
  List<Object> get props => [];
}

class LoadUserTrainings extends TrainingsEvent {
  final int userId;

  const LoadUserTrainings(this.userId);

  @override
  List<Object> get props => [userId];
}
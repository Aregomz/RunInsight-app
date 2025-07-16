part of 'ia_coach_bloc.dart';

abstract class IaCoachState {}

class IaCoachInitial extends IaCoachState {}
class IaCoachLoading extends IaCoachState {}
class IaCoachLoaded extends IaCoachState {
  final List<IaPredictionEntity> predictions;
  IaCoachLoaded(this.predictions);
}
class IaCoachError extends IaCoachState {
  final String message;
  IaCoachError(this.message);
}

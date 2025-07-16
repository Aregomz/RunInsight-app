part of 'ia_coach_bloc.dart';

abstract class IaCoachEvent {}

class IaCoachRequested extends IaCoachEvent {
  final Map<String, dynamic> userStats;
  final List<Map<String, dynamic>> lastTrainings;
  IaCoachRequested({required this.userStats, required this.lastTrainings});
}

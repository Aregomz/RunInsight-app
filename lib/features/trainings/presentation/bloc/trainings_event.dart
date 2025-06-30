part of 'trainings_bloc.dart';

abstract class TrainingsEvent {}

class LoadTrainings extends TrainingsEvent {}

class LoadTrainingsRequested extends TrainingsEvent {}
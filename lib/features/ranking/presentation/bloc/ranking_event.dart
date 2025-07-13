// features/ranking/presentation/bloc/ranking_event.dart
part of 'ranking_bloc.dart';

abstract class RankingEvent {}

class LoadRankingRequested extends RankingEvent {
  final String userId;

  LoadRankingRequested(this.userId);
}

class LoadBadgesRequested extends RankingEvent {
  final int userId;

  LoadBadgesRequested(this.userId);
}

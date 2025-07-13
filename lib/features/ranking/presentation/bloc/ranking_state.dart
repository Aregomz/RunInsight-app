// features/ranking/presentation/bloc/ranking_state.dart
part of 'ranking_bloc.dart';

abstract class RankingState {}

class RankingInitial extends RankingState {}

class RankingLoading extends RankingState {}

class RankingLoaded extends RankingState {
  final List<RankingUserEntity> entries;
  final String userId;
  final int userPosition;

  RankingLoaded({
    required this.entries,
    required this.userId,
    required this.userPosition,
  });
}

class BadgesLoading extends RankingState {}

class BadgesLoaded extends RankingState {
  final List<BadgeEntity> badges;

  BadgesLoaded({required this.badges});
}

class RankingError extends RankingState {
  final String message;

  RankingError(this.message);
}

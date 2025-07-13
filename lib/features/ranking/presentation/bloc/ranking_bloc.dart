// features/ranking/presentation/bloc/ranking_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:runinsight/features/ranking/domain/entities/ranking_entry_entity.dart';
import 'package:runinsight/features/ranking/domain/usecases/get_ranking.dart';
import 'package:runinsight/features/ranking/domain/usecases/get_user_position.dart';
import 'package:runinsight/features/ranking/domain/usecases/get_user_badges.dart';
import 'package:runinsight/features/ranking/domain/entities/ranking_user_entity.dart';
import 'package:runinsight/features/ranking/domain/entities/badge_entity.dart';

part 'ranking_event.dart';
part 'ranking_state.dart';

class RankingBloc extends Bloc<RankingEvent, RankingState> {
  final GetRankingUseCase getRankingUseCase;
  final GetUserPosition getUserPosition;
  final GetUserBadges getUserBadges;

  RankingBloc({
    required this.getRankingUseCase, 
    required this.getUserPosition,
    required this.getUserBadges,
  }) : super(RankingInitial()) {
    on<LoadRankingRequested>(_onLoad);
    on<LoadBadgesRequested>(_onLoadBadges);
  }

  Future<void> _onLoad(LoadRankingRequested event, Emitter<RankingState> emit) async {
    emit(RankingLoading());
    try {
      final entries = await getRankingUseCase(event.userId);
      final userPosition = await getUserPosition(event.userId);
      emit(RankingLoaded(entries: entries, userId: event.userId, userPosition: userPosition));
    } catch (_) {
      emit(RankingError("No se pudo cargar el ranking"));
    }
  }

  Future<void> _onLoadBadges(LoadBadgesRequested event, Emitter<RankingState> emit) async {
    emit(BadgesLoading());
    try {
      final badges = await getUserBadges(event.userId);
      emit(BadgesLoaded(badges: badges));
    } catch (e) {
      emit(RankingError("No se pudieron cargar las insignias: $e"));
    }
  }
}
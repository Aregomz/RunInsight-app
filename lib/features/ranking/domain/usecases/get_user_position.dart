// import 'package:runinsight/features/ranking/domain/entities/ranking_entry_entity.dart';
import 'package:runinsight/features/ranking/domain/repositories/ranking_repository.dart';

class GetUserPosition {
  final RankingRepository repository;

  GetUserPosition(this.repository);

  /// Retorna la posición (1-based) del usuario dado su ID.
  Future<int> call(String userId) async {
    final ranking = await repository.getRanking(userId);
    final sorted = ranking
      ..sort((a, b) {
        final aRatio = a.totalKm / (a.trainings > 0 ? a.trainings : 1);
        final bRatio = b.totalKm / (b.trainings > 0 ? b.trainings : 1);
        if (aRatio != bRatio) return bRatio.compareTo(aRatio);
        return b.trainings.compareTo(a.trainings);
      });

    final index = sorted.indexWhere((e) => e.id == userId);
    return index >= 0 ? index + 1 : -1; // Retorna -1 si no está
  }
}

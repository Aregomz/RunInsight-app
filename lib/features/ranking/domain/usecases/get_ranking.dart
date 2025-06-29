// features/ranking/domain/usecases/get_ranking_usecase.dart
import '../entities/ranking_user_entity.dart';
import '../repositories/ranking_repository.dart';

class GetRankingUseCase {
  final RankingRepository repository;

  GetRankingUseCase(this.repository);

  Future<List<RankingUserEntity>> call(String userId) async {
    return await repository.getRanking(userId);
  }
}
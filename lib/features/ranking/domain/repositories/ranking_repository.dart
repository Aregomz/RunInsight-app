// features/ranking/domain/repositories/ranking_repository.dart
import '../entities/ranking_user_entity.dart';

abstract class RankingRepository {
  Future<List<RankingUserEntity>> getRanking(String userId);
}
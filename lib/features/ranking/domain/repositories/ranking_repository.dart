// features/ranking/domain/repositories/ranking_repository.dart
import '../entities/ranking_user_entity.dart';
import '../entities/badge_entity.dart';

abstract class RankingRepository {
  Future<List<RankingUserEntity>> getRanking(String userId);
  Future<void> addFriend(int userId, int friendId);
  Future<List<BadgeEntity>> getUserBadges(int userId);
}
// features/ranking/domain/usecases/get_user_badges.dart
import '../entities/badge_entity.dart';
import '../repositories/ranking_repository.dart';

class GetUserBadges {
  final RankingRepository repository;

  GetUserBadges({required this.repository});

  Future<List<BadgeEntity>> call(int userId) async {
    return await repository.getUserBadges(userId);
  }
} 
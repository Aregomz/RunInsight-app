// features/ranking/domain/usecases/add_friend.dart
import '../repositories/ranking_repository.dart';

class AddFriendUseCase {
  final RankingRepository repository;

  AddFriendUseCase(this.repository);

  Future<void> call(int userId, int friendId) async {
    return await repository.addFriend(userId, friendId);
  }
} 
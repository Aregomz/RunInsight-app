// features/ranking/data/repositories/friends_ranking_repository_impl.dart
import 'package:runinsight/features/ranking/data/datasources/friends_ranking_remote_datasource.dart';
import 'package:runinsight/features/ranking/data/datasources/badges_remote_datasource.dart';
import 'package:runinsight/features/ranking/data/models/add_friend_request_model.dart';
import 'package:runinsight/features/ranking/domain/entities/ranking_user_entity.dart';
import 'package:runinsight/features/ranking/domain/entities/badge_entity.dart';
import 'package:runinsight/features/ranking/domain/repositories/ranking_repository.dart';
import 'package:runinsight/features/user/data/services/user_service.dart';

class FriendsRankingRepositoryImpl implements RankingRepository {
  final FriendsRankingRemoteDataSource remoteDataSource;
  final BadgesRemoteDataSource badgesRemoteDataSource;

  FriendsRankingRepositoryImpl({
    required this.remoteDataSource,
    required this.badgesRemoteDataSource,
  });

  @override
  Future<List<RankingUserEntity>> getRanking(String userId) async {
    try {
      final response = await remoteDataSource.getFriendsRanking(userId);
      
      if (response.success) {
        // Convertir los modelos a entidades
        final friends = response.friends.map((friend) => 
          RankingUserEntity(
            id: friend.id,
            name: friend.name,
            totalKm: friend.totalKm,
            trainings: friend.trainings,
          )
        ).toList();

        // Ordenar por promedio de km por entrenamiento y luego por número de entrenamientos
        friends.sort((a, b) {
          final aRatio = a.avgKmPerTraining;
          final bRatio = b.avgKmPerTraining;
          if (bRatio != aRatio) {
            return bRatio.compareTo(aRatio);
          } else {
            return b.trainings.compareTo(a.trainings);
          }
        });

        return friends;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Failed to load friends ranking: $e');
    }
  }

  @override
  Future<void> addFriend(int userId, int friendId) async {
    try {
      final request = AddFriendRequestModel(
        userId: userId,
        friendId: friendId,
      );
      await remoteDataSource.addFriend(request);
    } catch (e) {
      throw Exception('Failed to add friend: $e');
    }
  }

  @override
  Future<List<BadgeEntity>> getUserBadges(int userId) async {
    try {
      return await badgesRemoteDataSource.getUserBadges(userId);
    } catch (e) {
      throw Exception('Failed to load user badges: $e');
    }
  }
} 
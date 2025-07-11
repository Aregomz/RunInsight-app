// features/ranking/data/datasources/friends_ranking_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:runinsight/core/network/api_endpoints.dart';
import 'package:runinsight/features/ranking/data/models/friends_ranking_response_model.dart';

import 'package:runinsight/features/ranking/data/models/add_friend_request_model.dart';

abstract class FriendsRankingRemoteDataSource {
  Future<FriendsRankingResponseModel> getFriendsRanking(String userId);
  Future<void> addFriend(AddFriendRequestModel request);
}

class FriendsRankingRemoteDataSourceImpl implements FriendsRankingRemoteDataSource {
  final Dio dio;

  FriendsRankingRemoteDataSourceImpl({required this.dio});

  @override
  Future<FriendsRankingResponseModel> getFriendsRanking(String userId) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.friendsRanking}/$userId',
      );

      if (response.statusCode == 200) {
        return FriendsRankingResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load friends ranking');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Si no hay amigos, devolver lista vacía
        return const FriendsRankingResponseModel(
          message: 'No friends found',
          friends: [],
          success: true,
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<void> addFriend(AddFriendRequestModel request) async {
    try {
      final response = await dio.post(
        ApiEndpoints.addFriend,
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add friend');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
} 
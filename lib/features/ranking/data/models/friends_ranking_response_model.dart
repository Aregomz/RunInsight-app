// features/ranking/data/models/friends_ranking_response_model.dart
import 'package:runinsight/features/ranking/data/models/ranking_user_model.dart';

class FriendsRankingResponseModel {
  final String message;
  final List<RankingUserModel> friends;
  final bool success;

  const FriendsRankingResponseModel({
    required this.message,
    required this.friends,
    required this.success,
  });

  factory FriendsRankingResponseModel.fromJson(Map<String, dynamic> json) {
    return FriendsRankingResponseModel(
      message: json['message'] as String,
      friends: (json['friends'] as List<dynamic>)
          .map((friend) => RankingUserModel.fromJson(friend))
          .toList(),
      success: json['success'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'friends': friends.map((friend) => friend.toJson()).toList(),
      'success': success,
    };
  }
} 
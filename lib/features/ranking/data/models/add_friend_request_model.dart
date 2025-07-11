// features/ranking/data/models/add_friend_request_model.dart
class AddFriendRequestModel {
  final int userId;
  final int friendId;

  const AddFriendRequestModel({
    required this.userId,
    required this.friendId,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'friendId': friendId,
    };
  }
} 
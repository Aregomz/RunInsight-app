// features/profile/domain/repositories/profile_repository.dart
import '../entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<UserProfileEntity> getProfile();
  Future<void> updateProfile(String userId, {required int height, required double weight, required String experience});
}

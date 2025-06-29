// features/profile/domain/repositories/profile_repository.dart
import '../entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<UserProfileEntity> getProfile();
  Future<void> updateProfile({required int heightCm, required double weightKg});
}

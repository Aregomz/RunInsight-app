// features/profile/domain/usecases/get_user_profile.dart
import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetUserProfile {
  final ProfileRepository repository;
  GetUserProfile(this.repository);

  Future<UserProfileEntity> call() => repository.getProfile();
}
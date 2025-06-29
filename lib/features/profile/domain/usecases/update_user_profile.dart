// features/profile/domain/usecases/update_user_profile.dart
import '../repositories/profile_repository.dart';

class UpdateUserProfile {
  final ProfileRepository repository;
  UpdateUserProfile(this.repository);

  Future<void> call({required int heightCm, required double weightKg}) {
    return repository.updateProfile(heightCm: heightCm, weightKg: weightKg);
  }
}
// features/profile/domain/usecases/update_profile_usecase.dart
import 'package:runinsight/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase({required this.repository});

  Future<void> call(String userId, {required int height, required double weight, required String experience}) async {
    await repository.updateProfile(userId, height: height, weight: weight, experience: experience);
  }
} 
// features/profile/data/repositories/profile_repository_impl.dart
import 'package:runinsight/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:runinsight/features/profile/domain/repositories/profile_repository.dart';
import 'package:runinsight/features/profile/domain/entities/user_profile_entity.dart';
import '../models/profile_update_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserProfileEntity> getProfile() {
    // TODO: Implementar obtención del perfil
    throw UnimplementedError();
  }

  @override
  Future<void> updateProfile(String userId, {required int height, required double weight, required String experience}) async {
    final profileData = ProfileUpdateModel(
      weight: weight,
      height: height,
      experience: experience,
    );
    await remoteDataSource.updateProfile(userId, profileData);
  }
} 
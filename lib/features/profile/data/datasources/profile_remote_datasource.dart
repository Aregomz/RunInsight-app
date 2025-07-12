// features/profile/data/datasources/profile_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:runinsight/core/network/api_endpoints.dart';
import 'package:runinsight/core/network/dio_client.dart';
import '../models/profile_update_model.dart';

abstract class ProfileRemoteDataSource {
  Future<void> updateProfile(String userId, ProfileUpdateModel profileData);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  @override
  Future<void> updateProfile(String userId, ProfileUpdateModel profileData) async {
    try {
      final response = await DioClient.instance.patch(
        '${ApiEndpoints.users}/$userId',
        data: profileData.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al actualizar el perfil');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
} 
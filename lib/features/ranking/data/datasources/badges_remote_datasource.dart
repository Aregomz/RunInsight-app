// features/ranking/data/datasources/badges_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:runinsight/core/network/api_endpoints.dart';
import 'package:runinsight/core/network/dio_client.dart';
import '../models/badge_model.dart';

abstract class BadgesRemoteDataSource {
  Future<List<BadgeModel>> getAllBadges();
  Future<BadgeModel> getBadgeById(int id);
  Future<List<BadgeModel>> getUserBadges(int userId);
}

class BadgesRemoteDataSourceImpl implements BadgesRemoteDataSource {
  @override
  Future<List<BadgeModel>> getAllBadges() async {
    try {
      final response = await DioClient.instance.get('/users/badges/all');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final badgesList = data['badges'] as List;
        
        return badgesList
            .map((badgeJson) => BadgeModel.fromJson(badgeJson))
            .toList();
      } else {
        throw Exception('Error al obtener insignias');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<BadgeModel> getBadgeById(int id) async {
    try {
      final response = await DioClient.instance.get('/users/badges/$id');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final badgeData = data['badge'] as Map<String, dynamic>;
        
        return BadgeModel.fromJson(badgeData);
      } else {
        throw Exception('Error al obtener insignia');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<List<BadgeModel>> getUserBadges(int userId) async {
    try {
      final response = await DioClient.instance.get('/users/badges/user/$userId');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final badgesList = data['badges'] as List;
        
        return badgesList
            .map((badgeJson) => BadgeModel.fromJson(badgeJson))
            .toList();
      } else {
        throw Exception('Error al obtener insignias del usuario');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
} 
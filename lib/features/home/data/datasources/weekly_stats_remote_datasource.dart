// features/home/data/datasources/weekly_stats_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/weekly_stats_response_model.dart';

abstract class WeeklyStatsRemoteDataSource {
  Future<WeeklyStatsResponseModel> getWeeklyStats(int userId);
}

class WeeklyStatsRemoteDataSourceImpl implements WeeklyStatsRemoteDataSource {
  final Dio dio;

  WeeklyStatsRemoteDataSourceImpl({required this.dio});

  @override
  Future<WeeklyStatsResponseModel> getWeeklyStats(int userId) async {
    try {
      print('📊 Obteniendo estadísticas semanales del usuario $userId');
      
      final response = await dio.get(
        '${ApiEndpoints.trainings}/weekly-distance/$userId',
      );

      print('✅ Respuesta de estadísticas semanales: ${response.data}');

      if (response.statusCode == 200) {
        return WeeklyStatsResponseModel.fromJson(response.data);
      } else {
        throw Exception('Error al obtener estadísticas semanales: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Error DioException al obtener estadísticas semanales: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      throw Exception('Error de red al obtener estadísticas semanales: ${e.message}');
    } catch (e) {
      print('❌ Error inesperado al obtener estadísticas semanales: $e');
      throw Exception('Error inesperado al obtener estadísticas semanales: $e');
    }
  }
} 
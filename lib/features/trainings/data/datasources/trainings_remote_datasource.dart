// features/trainings/data/datasources/trainings_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/training_response_model.dart';

abstract class TrainingsRemoteDataSource {
  Future<TrainingResponseModel> getUserTrainings(int userId);
}

class TrainingsRemoteDataSourceImpl implements TrainingsRemoteDataSource {
  final Dio dio;

  TrainingsRemoteDataSourceImpl({required this.dio});

  @override
  Future<TrainingResponseModel> getUserTrainings(int userId) async {
    try {
      print('📡 Obteniendo entrenamientos del usuario $userId');
      
      final response = await dio.get(
        '${ApiEndpoints.trainings}/user/$userId',
      );

      print('✅ Respuesta de entrenamientos: ${response.data}');

      if (response.statusCode == 200) {
        return TrainingResponseModel.fromJson(response.data);
      } else {
        throw Exception('Error al obtener entrenamientos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Error DioException al obtener entrenamientos: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      throw Exception('Error de red al obtener entrenamientos: ${e.message}');
    } catch (e) {
      print('❌ Error inesperado al obtener entrenamientos: $e');
      throw Exception('Error inesperado al obtener entrenamientos: $e');
    }
  }
} 
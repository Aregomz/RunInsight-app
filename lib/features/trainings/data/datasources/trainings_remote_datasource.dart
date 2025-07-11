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
      print('❌ Status Code: ${e.response?.statusCode}');
      print('❌ Response Data: ${e.response?.data}');
      
      // Si es un error 404, 204, o similar, devolver lista vacía para usuarios nuevos
      if (e.response?.statusCode == 404 || 
          e.response?.statusCode == 204 ||
          e.response?.statusCode == 400) {
        print('📡 Usuario nuevo sin entrenamientos (${e.response?.statusCode}), devolviendo lista vacía');
        return TrainingResponseModel(
          message: 'No hay entrenamientos disponibles aún',
          trainings: [],
          success: true,
        );
      }
      
      // Si el mensaje del backend indica que no hay datos
      if (e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          final message = responseData['message']?.toString().toLowerCase() ?? '';
          if (message.contains('no hay') || 
              message.contains('empty') || 
              message.contains('not found') ||
              message.contains('sin entrenamientos')) {
            print('📡 Backend indica que no hay entrenamientos, devolviendo lista vacía');
            return TrainingResponseModel(
              message: 'No hay entrenamientos disponibles aún',
              trainings: [],
              success: true,
            );
          }
        }
      }
      
      throw Exception('Error de red al obtener entrenamientos: ${e.message}');
    } catch (e) {
      print('❌ Error inesperado al obtener entrenamientos: $e');
      throw Exception('Error inesperado al obtener entrenamientos: $e');
    }
  }
} 
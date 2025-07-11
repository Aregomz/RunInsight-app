import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/active_training_request_model.dart';
import '../../../../features/user/data/services/user_service.dart';

abstract class ActiveTrainingRemoteDatasource {
  Future<void> sendActiveTraining(ActiveTrainingRequestModel request);
}

class ActiveTrainingRemoteDatasourceImpl implements ActiveTrainingRemoteDatasource {
  final Dio _dio = DioClient.instance;

  // Función para decodificar JWT y obtener el payload
  Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return {};
      }
      
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);
      return payloadMap;
    } catch (e) {
      print('❌ Error decodificando JWT: $e');
      return {};
    }
  }

  @override
  Future<void> sendActiveTraining(ActiveTrainingRequestModel request) async {
    // Verificar el token ANTES de cualquier operación
    final token = UserService.getAuthToken();
    print('🔍 Verificando token antes de enviar entrenamiento:');
    print('   Token disponible: ${token != null ? 'SÍ' : 'NO'}');
    
    if (token != null) {
      final tokenPayload = _decodeJwt(token);
      print('🔍 Token JWT decodificado:');
      print('   User ID en token: ${tokenPayload['id']}');
      print('   Token expira: ${DateTime.fromMillisecondsSinceEpoch(tokenPayload['exp'] * 1000)}');
      print('   Token emitido: ${DateTime.fromMillisecondsSinceEpoch(tokenPayload['iat'] * 1000)}');
    } else {
      print('⚠️ NO HAY TOKEN DISPONIBLE');
    }
    
    try {
      final url = ApiEndpoints.getFullUrl(ApiEndpoints.trainings);
      final requestData = request.toJson();
      
      print('🏃 Enviando entrenamiento al backend:');
      print('   URL: $url');
      print('   Data: $requestData');
      
      final response = await _dio.post(url, data: requestData);
      
      print('✅ Entrenamiento enviado exitosamente');
      print('   Status: ${response.statusCode}');
      print('   Response: ${response.data}');
      
    } catch (e) {
      print('❌ Error enviando entrenamiento: $e');
      
      if (e is DioException) {
        print('🔍 Detalles del error DioException:');
        print('   Type: ${e.type}');
        print('   Message: ${e.message}');
        
        if (e.response != null) {
          print('   Status Code: ${e.response!.statusCode}');
          print('   Status Message: ${e.response!.statusMessage}');
          print('   Response Data: ${e.response!.data}');
          print('   Response Headers: ${e.response!.headers}');
          
          // Intentar extraer mensaje específico del backend
          if (e.response!.data is Map<String, dynamic>) {
            final data = e.response!.data as Map<String, dynamic>;
            final message = data['message'] ?? 'Sin mensaje';
            final error = data['error'] ?? 'Sin error específico';
            print('   Backend Message: $message');
            print('   Backend Error: $error');
            
            // Lanzar excepción con mensaje más específico
            throw Exception('Error del backend: $message - $error');
          }
        }
        
        // Si no hay response, puede ser error de conexión
        if (e.type == DioExceptionType.connectionTimeout) {
          throw Exception('Error de conexión: Timeout al conectar con el servidor');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          throw Exception('Error de conexión: Timeout al recibir respuesta del servidor');
        } else if (e.type == DioExceptionType.connectionError) {
          throw Exception('Error de conexión: No se pudo conectar con el servidor');
        }
        
        throw Exception('Error al guardar entrenamiento: ${e.message}');
      } else {
        throw Exception('Error inesperado: $e');
      }
    }
  }
} 
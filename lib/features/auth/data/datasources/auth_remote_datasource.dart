import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/auth_response_model.dart';
import '../models/register_request_model.dart';

// Excepciones personalizadas para errores específicos
class AuthException implements Exception {
  final String message;
  final String type;
  
  AuthException(this.message, this.type);
  
  @override
  String toString() => message;
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException() : super('Credenciales incorrectas', 'credentials');
}

class UserNotFoundException extends AuthException {
  UserNotFoundException() : super('Usuario no encontrado', 'user_not_found');
}

class WrongPasswordException extends AuthException {
  WrongPasswordException() : super('Contraseña incorrecta', 'wrong_password');
}

class ServerException extends AuthException {
  ServerException() : super('Error del servidor', 'server_error');
}

class NetworkException extends AuthException {
  NetworkException() : super('Error de conexión a internet', 'network_error');
}

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<AuthResponseModel> register(RegisterRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio = DioClient.instance;

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponseModel.fromJson(response.data);
        
        if (authResponse.token != null || authResponse.accessToken != null) {
          final token = authResponse.token ?? authResponse.accessToken!;
          final userData = authResponse.user;
          
          final userInfo = {
            'id': userData?.id,
            'token': token,
            'rolesId': userData?.rolesId,
          };
          
          print('🔑 Token guardado: $token');
        }
        
        return authResponse;
      } else {
        print('❌ Error HTTP: ${response.statusCode} - ${response.data}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      // Manejar errores específicos de Dio
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException();
      }
      
      if (e.type == DioExceptionType.connectionError) {
        throw NetworkException();
      }
      
      // Manejar errores de respuesta del servidor
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        
        print('🔍 Error completo del backend:');
        print('   Status Code: $statusCode');
        print('   Response Data: $responseData');
        print('   Response Headers: ${e.response!.headers}');
        
        // Intentar extraer mensaje específico del backend
        String errorMessage = '';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString().toLowerCase() ?? '';
          // También buscar en el campo 'error' si existe
          if (errorMessage.isEmpty) {
            errorMessage = responseData['error']?.toString().toLowerCase() ?? '';
          }
        }
        
        print('🔍 Error del backend - Status: $statusCode, Message: $errorMessage');
        
        // Analizar el mensaje del backend para determinar el tipo de error específico
        if (errorMessage.contains('password') || errorMessage.contains('contraseña') || 
            errorMessage.contains('incorrecta') || errorMessage.contains('wrong')) {
          throw WrongPasswordException();
        } else if (errorMessage.contains('user') || errorMessage.contains('usuario') || 
                   errorMessage.contains('email') || errorMessage.contains('not found') ||
                   errorMessage.contains('no encontrado') || errorMessage.contains('does not exist')) {
          throw UserNotFoundException();
        } else if (errorMessage.contains('credentials') || errorMessage.contains('credenciales') ||
                   errorMessage.contains('invalid') || errorMessage.contains('inválido')) {
          throw InvalidCredentialsException();
        } else if (statusCode == 401) {
          // Si es 401 pero no pudimos determinar el tipo específico
          throw InvalidCredentialsException();
        } else if (statusCode == 404) {
          throw UserNotFoundException();
        } else if (statusCode == 500) {
          // Si es 500, intentar determinar si es un error específico o del servidor
          if (errorMessage.contains('server') || errorMessage.contains('servidor') ||
              errorMessage.contains('internal') || errorMessage.contains('database')) {
            throw ServerException();
          } else {
            // Si no podemos determinar, asumir que es un error de credenciales
            throw InvalidCredentialsException();
          }
        } else {
          // Error genérico basado en el mensaje del backend
          if (errorMessage.isNotEmpty) {
            throw AuthException(errorMessage, 'backend_error');
          } else {
            throw AuthException('Error al iniciar sesión', 'unknown');
          }
        }
      }
      
      // Error genérico de Dio
      throw AuthException('Error de conexión', 'dio_error');
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Error inesperado: ${e.toString()}', 'unknown');
    }
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponseModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException();
      }
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        
        String errorMessage = '';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString().toLowerCase() ?? '';
        }
        
        if (statusCode == 409) {
          throw AuthException('El email o username ya están registrados', 'duplicate');
        } else if (statusCode == 400) {
          throw AuthException('Datos inválidos. Verifica la información', 'validation');
        } else if (statusCode == 500) {
          throw ServerException();
        } else {
          if (errorMessage.isNotEmpty) {
            throw AuthException(errorMessage, 'backend_error');
          } else {
            throw AuthException('Error al registrar usuario', 'unknown');
          }
        }
      }
      
      throw AuthException('Error de conexión', 'dio_error');
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Error inesperado: ${e.toString()}', 'unknown');
    }
  }
} 
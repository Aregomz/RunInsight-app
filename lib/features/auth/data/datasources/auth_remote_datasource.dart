import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/auth_response_model.dart';
import '../models/register_request_model.dart';

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
        
        // Si el login es exitoso, guardar el token en UserService
        if (authResponse.token != null || authResponse.accessToken != null) {
          final token = authResponse.token ?? authResponse.accessToken!;
          final userData = authResponse.user;
          
          final userInfo = {
            'id': userData?.id,
            'token': token,
            'rolesId': userData?.rolesId,
          };
          
          // Importar UserService aquí para evitar dependencias circulares
          // UserService.setAuthToken(token, userInfo);
          print('🔑 Token guardado: $token');
        }
        
        return authResponse;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.login),
        error: DioClient.handleError(e),
        type: DioExceptionType.unknown,
      );
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
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.register),
        error: DioClient.handleError(e),
        type: DioExceptionType.unknown,
      );
    }
  }
} 
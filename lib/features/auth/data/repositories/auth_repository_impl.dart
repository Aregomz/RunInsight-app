import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/register_request_model.dart';
import '../models/auth_response_model.dart';
import '../services/auth_persistence_service.dart';
import '../../../user/data/services/user_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<void> loginUser(String email, String password) async {
    try {
      final response = await _remoteDataSource.login(email, password);
      
      // Guardar datos de autenticación de manera persistente
      await AuthPersistenceService.saveAuthData(response);
      
      // También mantener compatibilidad con UserService
      final token = response.user?.token ?? response.token ?? response.accessToken;
      final userData = response.user;
      
      if (token != null) {
        final userInfo = {
          'id': userData?.id,
          'token': token,
          'rolesId': userData?.rolesId,
        };
        
        UserService.setAuthToken(token, userInfo);
        print('✅ Login exitoso para: ${userData?.email ?? email}');
        print('🔑 Token guardado persistentemente: $token');
      } else {
        throw Exception('No se recibió token de autenticación');
      }
    } catch (e) {
      throw Exception('Error en login: $e');
    }
  }

  @override
  Future<void> registerUser(UserEntity user) async {
    try {
      final request = RegisterRequestModel(
        name: user.name,
        email: user.email,
        username: user.username,
        password: user.password,
        gender: user.gender,
        birthdate: '${user.birthDate.year.toString().padLeft(4, '0')}-${user.birthDate.month.toString().padLeft(2, '0')}-${user.birthDate.day.toString().padLeft(2, '0')}',
        expLevel: user.expLevel,
        weight: user.weight,
        height: user.height,
      );

      await _remoteDataSource.register(request);
    } catch (e) {
      throw Exception('Error en registro: $e');
    }
  }
} 
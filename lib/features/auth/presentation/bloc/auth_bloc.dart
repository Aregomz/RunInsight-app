// features/auth/presentation/bloc/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import '../../../user/data/services/user_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        print('🔐 Iniciando login para: ${event.email}');
        
        // Usar el repository para hacer login
        await _authRepository.loginUser(event.email, event.password);
        
        // Si llegamos aquí, el login fue exitoso
        print('✅ Login exitoso');
        emit(AuthSuccess());
      } catch (e) {
        print('❌ Error en login: $e');
        
        // Manejar errores basados en el mensaje
        String errorMessage = e.toString();
        
        if (errorMessage.contains('Contraseña incorrecta')) {
          emit(AuthFailure('Contraseña incorrecta. Verifica tu contraseña.'));
        } else if (errorMessage.contains('Usuario no encontrado')) {
          emit(AuthFailure('Usuario no encontrado. Verifica tu email o nombre de usuario.'));
        } else if (errorMessage.contains('Credenciales incorrectas')) {
          emit(AuthFailure('Credenciales incorrectas. Verifica tu email y contraseña.'));
        } else if (errorMessage.contains('Error del servidor')) {
          emit(AuthFailure('Error del servidor. Intenta más tarde.'));
        } else if (errorMessage.contains('Error de conexión a internet')) {
          emit(AuthFailure('Error de conexión a internet. Verifica tu conexión.'));
        } else if (e is DioException) {
          // Fallback para errores de Dio no manejados
          if (e.response?.statusCode == 401) {
            emit(AuthFailure('Credenciales incorrectas. Verifica tu email y contraseña.'));
          } else if (e.response?.statusCode == 404) {
            emit(AuthFailure('Usuario no encontrado. Verifica tu email.'));
          } else if (e.response?.statusCode == 500) {
            emit(AuthFailure('Error del servidor. Intenta más tarde.'));
          } else if (e.type == DioExceptionType.connectionTimeout || 
                     e.type == DioExceptionType.receiveTimeout) {
            emit(AuthFailure('Error de conexión. Verifica tu internet.'));
          } else {
            emit(AuthFailure('Error inesperado. Intenta nuevamente.'));
          }
        } else {
          // Error genérico
          emit(AuthFailure('Error al iniciar sesión. Intenta nuevamente.'));
        }
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        print('🌐 Iniciando registro para: ${event.email}');
        
        // Crear la entidad del usuario
        final userEntity = UserEntity(
          name: event.name,
          email: event.email,
          username: event.username,
          password: event.password,
          birthDate: _parseBirthDate(event.age),
          gender: event.gender,
          weight: double.tryParse(event.weight) ?? 0.0,
          height: int.tryParse(event.height) ?? 0,
          expLevel: event.expLevel,
        );
        
        // Usar el repository para hacer registro
        await _authRepository.registerUser(userEntity);
        
        print('✅ Usuario registrado exitosamente');
        emit(AuthSuccess());
      } catch (e) {
        print('❌ Error en registro: $e');
        
        // Manejar errores basados en el mensaje
        String errorMessage = e.toString();
        
        if (errorMessage.contains('Error del servidor')) {
          emit(AuthFailure('Error del servidor. Intenta más tarde.'));
        } else if (errorMessage.contains('Error de conexión a internet')) {
          emit(AuthFailure('Error de conexión a internet. Verifica tu conexión.'));
        } else if (errorMessage.contains('ya están registrados')) {
          emit(AuthFailure('El email o username ya están registrados.'));
        } else if (errorMessage.contains('Datos inválidos')) {
          emit(AuthFailure('Datos inválidos. Verifica la información.'));
        } else if (e is DioException) {
          // Fallback para errores de Dio no manejados
          if (e.response?.statusCode == 409) {
            emit(AuthFailure('El email o username ya están registrados.'));
          } else if (e.response?.statusCode == 400) {
            emit(AuthFailure('Datos inválidos. Verifica la información.'));
          } else if (e.response?.statusCode == 500) {
            emit(AuthFailure('Error del servidor. Intenta más tarde.'));
          } else if (e.type == DioExceptionType.connectionTimeout || 
                     e.type == DioExceptionType.receiveTimeout) {
            emit(AuthFailure('Error de conexión. Verifica tu internet.'));
          } else {
            emit(AuthFailure('Error inesperado. Intenta nuevamente.'));
          }
        } else {
          emit(AuthFailure('Error al registrar usuario. Intenta nuevamente.'));
        }
      }
    });
  }

  DateTime _parseBirthDate(String age) {
    // Convertir edad a fecha de nacimiento
    int ageInt = int.tryParse(age) ?? 25;
    DateTime now = DateTime.now();
    return now.subtract(Duration(days: ageInt * 365));
  }
}

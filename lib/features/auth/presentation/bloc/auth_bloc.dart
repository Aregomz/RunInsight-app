// features/auth/presentation/bloc/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
        emit(AuthFailure(e.toString()));
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
        emit(AuthFailure(e.toString()));
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

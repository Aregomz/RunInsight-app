import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/services/user_service.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    print('🔧 UserBloc inicializado');
    on<LoadUserData>(_onLoadUserData);
    on<LoadUserProfile>(_onLoadUserProfile);
    on<LoadCurrentUser>(_onLoadCurrentUser);
  }

  Future<void> _onLoadUserData(
    LoadUserData event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      // Intentar obtener datos del usuario actual con token
      final userData = await UserService.getCurrentUser();
      emit(UserLoaded(userData: userData));
    } catch (e) {
      emit(
        UserError(
          message:
              'No se pudo obtener datos del usuario. Debes hacer login primero: $e',
        ),
      );
    }
  }

  Future<void> _onLoadCurrentUser(
    LoadCurrentUser event,
    Emitter<UserState> emit,
  ) async {
    print('🔄 Cargando datos del usuario actual...');
    emit(UserLoading());
    try {
      final userData = await UserService.getCurrentUser();
      print('✅ Datos del usuario cargados exitosamente: $userData');
      print('🔍 Username en UserBloc: ${userData['username']}');
      print('🔍 Name en UserBloc: ${userData['name']}');
      emit(UserLoaded(userData: userData));
    } catch (e) {
      print('❌ Error al cargar datos del usuario: $e');
      
      // Para usuarios nuevos o errores de red, usar datos por defecto
      if (e.toString().contains('No hay token') || 
          e.toString().contains('Error de red') ||
          e.toString().contains('404')) {
        print('👤 Usuario nuevo o error de red, usando datos por defecto');
        emit(UserLoaded(userData: {
          'username': 'Usuario',
          'name': 'Usuario',
          'email': 'usuario@runinsight.com',
          'stats': {
            'km_total': 0.0,
            'training_counter': 0,
            'training_streak': 0,
            'best_rhythm': 0.0,
          }
        }));
      } else {
        emit(
          UserError(
            message:
                'No se pudo obtener datos del usuario. Debes hacer login primero: $e',
          ),
        );
      }
    }
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final profileData = await UserService.getUserProfile(event.userId);
      emit(UserProfileLoaded(profileData: profileData));
    } catch (e) {
      emit(UserError(message: 'No se pudo obtener perfil: $e'));
    }
  }
}

// features/auth/presentation/cubit/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      await Future.delayed(const Duration(seconds: 2));
      if (event.email == 'test@email.com' && event.password == '1234') {
        emit(AuthSuccess());
      } else {
        emit(AuthFailure("Credenciales incorrectas"));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      await Future.delayed(const Duration(seconds: 2)); // Simula petición

      // Simulación básica de éxito
      emit(AuthSuccess());
    });
  }
}  
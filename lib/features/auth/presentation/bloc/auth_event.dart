// features/auth/presentation/cubit/auth_event.dart
part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String username;
  final String age;
  final String gender;
  final String password;
  final String weight;
  final String height;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.username,
    required this.age,
    required this.gender,
    required this.password,
    required this.weight,
    required this.height,
  });

  @override
  List<Object> get props => [name, email, username, age, gender, password, weight, height];
}
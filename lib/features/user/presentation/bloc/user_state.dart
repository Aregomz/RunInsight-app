part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final Map<String, dynamic> userData;

  const UserLoaded({required this.userData});

  @override
  List<Object> get props => [userData];
}

class UserProfileLoaded extends UserState {
  final Map<String, dynamic> profileData;

  const UserProfileLoaded({required this.profileData});

  @override
  List<Object> get props => [profileData];
}

class UserError extends UserState {
  final String message;

  const UserError({required this.message});

  @override
  List<Object> get props => [message];
}

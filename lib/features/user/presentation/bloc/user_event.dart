part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadUserData extends UserEvent {
  final String email;

  const LoadUserData({required this.email});

  @override
  List<Object> get props => [email];
}

class LoadCurrentUser extends UserEvent {
  const LoadCurrentUser();
}

class LoadUserProfile extends UserEvent {
  final String userId;

  const LoadUserProfile({required this.userId});

  @override
  List<Object> get props => [userId];
}

// features/profile/presentation/bloc/profile_state.dart
part of 'profile_bloc.dart';

sealed class ProfileState {}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final UserProfileEntity user;
  final bool isEditing;

  ProfileLoaded({required this.user, this.isEditing = false});
}
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

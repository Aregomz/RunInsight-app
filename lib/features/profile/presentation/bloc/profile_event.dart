// features/profile/presentation/bloc/profile_event.dart
part of 'profile_bloc.dart';

sealed class ProfileEvent {}

class LoadProfile extends ProfileEvent {}
class EditProfileToggled extends ProfileEvent {}
class UpdateProfileSubmitted extends ProfileEvent {
  final int heightCm;
  final double weightKg;

  UpdateProfileSubmitted({required this.heightCm, required this.weightKg});
}
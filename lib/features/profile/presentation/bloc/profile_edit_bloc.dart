// features/profile/presentation/bloc/profile_edit_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/update_profile_usecase.dart';

// Events
abstract class ProfileEditEvent extends Equatable {
  const ProfileEditEvent();

  @override
  List<Object?> get props => [];
}

class UpdateProfileEvent extends ProfileEditEvent {
  final String userId;
  final int height;
  final double weight;
  final String experience;

  const UpdateProfileEvent({
    required this.userId,
    required this.height,
    required this.weight,
    required this.experience,
  });

  @override
  List<Object?> get props => [userId, height, weight, experience];
}

// States
abstract class ProfileEditState extends Equatable {
  const ProfileEditState();

  @override
  List<Object?> get props => [];
}

class ProfileEditInitial extends ProfileEditState {}

class ProfileEditLoading extends ProfileEditState {}

class ProfileEditSuccess extends ProfileEditState {}

class ProfileEditError extends ProfileEditState {
  final String message;

  const ProfileEditError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ProfileEditBloc extends Bloc<ProfileEditEvent, ProfileEditState> {
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileEditBloc({required this.updateProfileUseCase}) : super(ProfileEditInitial()) {
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileEditState> emit,
  ) async {
    emit(ProfileEditLoading());

    try {
      await updateProfileUseCase(
        event.userId,
        height: event.height,
        weight: event.weight,
        experience: event.experience,
      );
      emit(ProfileEditSuccess());
    } catch (e) {
      String errorMessage = 'Error al actualizar el perfil';
      
      if (e.toString().contains('User not found')) {
        errorMessage = 'Usuario no encontrado. Por favor, inicia sesión nuevamente.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Error del servidor. Inténtalo más tarde.';
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        errorMessage = 'Sesión expirada. Por favor, inicia sesión nuevamente.';
      }
      
      emit(ProfileEditError(errorMessage));
    }
  }
} 
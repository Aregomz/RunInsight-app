// features/profile/presentation/bloc/profile_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/update_profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfile getUserProfile;
  final UpdateProfileUseCase updateUserProfile;

  ProfileBloc({required this.getUserProfile, required this.updateUserProfile})
      : super(ProfileInitial()) {
    on<LoadProfile>(_onLoad);
    on<EditProfileToggled>(_onToggleEdit);
    on<UpdateProfileSubmitted>(_onUpdate);
  }

  Future<void> _onLoad(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final user = await getUserProfile();
      emit(ProfileLoaded(user: user));
    } catch (e) {
      emit(ProfileError('Error al cargar el perfil'));
    }
  }

  void _onToggleEdit(EditProfileToggled event, Emitter<ProfileState> emit) {
    if (state is ProfileLoaded) {
      final current = state as ProfileLoaded;
      emit(ProfileLoaded(user: current.user, isEditing: !current.isEditing));
    }
  }

  Future<void> _onUpdate(UpdateProfileSubmitted event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoaded) {
      final current = state as ProfileLoaded;
      emit(ProfileLoading());
      try {
        await updateUserProfile('1', height: event.heightCm, weight: event.weightKg, experience: 'Principiante');
        final user = await getUserProfile();
        emit(ProfileLoaded(user: user));
      } catch (e) {
        emit(ProfileError('Error al actualizar'));
      }
    }
  }
}

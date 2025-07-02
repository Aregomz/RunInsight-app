// features/profile/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runinsight/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:runinsight/features/profile/presentation/widgets/profile_form.dart';
import 'package:runinsight/features/profile/presentation/widgets/profile_header.dart';
import 'package:runinsight/features/profile/domain/entities/user_profile_entity.dart';
import 'package:runinsight/features/profile/domain/usecases/get_user_profile.dart';
import 'package:runinsight/features/profile/domain/usecases/update_user_profile.dart';
import 'package:runinsight/features/profile/domain/repositories/profile_repository.dart';
import 'package:go_router/go_router.dart';


// Dummy implementation para desarrollo
class DummyProfileRepository implements ProfileRepository {
  @override
  Future<UserProfileEntity> getProfile() async {
    return UserProfileEntity(
      username: 'Aregomz',
      fullName: 'Antonio Arellanes',
      heightCm: 170,
      weightKg: 70.0,
      bestPace: 6.14,
      totalKm: 421.2,
      totalWorkouts: 23,
    );
  }

  @override
  Future<void> updateProfile({required int heightCm, required double weightKg}) async {
    // No hace nada en dummy
    return;
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = DummyProfileRepository();
    return BlocProvider(
      create: (_) => ProfileBloc(
        getUserProfile: GetUserProfile(repository),
        updateUserProfile: UpdateUserProfile(repository),
      )..add(LoadProfile()),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError) {
            return Center(child: Text(state.message));
          }
          if (state is ProfileLoaded) {
            final user = state.user;
            if (!state.isEditing) {
              // Vista solo lectura
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Mi Perfil'),
                  backgroundColor: const Color(0xFF0A0A20),
                ),
                backgroundColor: const Color(0xFF0C0C27),
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: ProfileHeader(
                              name: user.fullName,
                              email: '@${user.username}',
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              _ProfileStatBox(
                                value: user.totalKm.toStringAsFixed(1),
                                label: 'km totales',
                              ),
                              const SizedBox(width: 16),
                              _ProfileStatBox(
                                value: user.totalWorkouts.toString(),
                                label: 'Entrenamientos',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: _ProfileStatBox(
                              value: user.bestPace.toStringAsFixed(2),
                              label: 'Mejor ritmo',
                              fullWidth: true,
                              verticalPadding: 10,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => context.read<ProfileBloc>().add(EditProfileToggled()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF23233B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: const BorderSide(color: Color(0xFFB0B0B0), width: 2),
                                ),
                              ),
                              child: const Text('Editar Perfil', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 105, 2, 2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: const BorderSide(color: Color.fromARGB(255, 255, 3, 3), width: 2),
                                ),
                              ),
                              child: const Text('Cerrar sesion', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // Vista edición
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Editar Perfil'),
                  backgroundColor: const Color(0xFF0A0A20),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (GoRouter.of(context).canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                ),
                backgroundColor: const Color(0xFF0C0C27),
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ProfileForm(
                    initialUsername: user.username,
                    initialGender: 'hombre', // Dummy
                    initialWeight: user.weightKg.toString(),
                    initialHeight: user.heightCm.toString(),
                  ),
                ),
              );
            }
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ProfileStatBox extends StatelessWidget {
  final String value;
  final String label;
  final bool fullWidth;
  final double verticalPadding;
  const _ProfileStatBox({
    required this.value,
    required this.label,
    this.fullWidth = false,
    this.verticalPadding = 18,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      margin: fullWidth ? null : const EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF181B23),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey[600]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFFF6A00),
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
    return fullWidth ? box : Expanded(child: box);
  }
}

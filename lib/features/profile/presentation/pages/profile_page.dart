// features/profile/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:runinsight/features/profile/presentation/widgets/profile_header.dart';
import 'package:runinsight/features/user/presentation/bloc/user_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserBloc()..add(const LoadCurrentUser()),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6A00)),
              );
            }

            if (state is UserError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<UserBloc>().add(const LoadCurrentUser());
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is UserLoaded) {
              final userData = state.userData;
              final name = userData['name'] ?? 'Usuario';
              final username = userData['username'] ?? '';
              final email = userData['email'] ?? '';
              final stats = userData['stats'] ?? {};

              // Datos de estadísticas del usuario desde la API
              final kmTotal = _formatDecimal(stats['km_total']) ?? '0.00';
              final trainingCounter =
                  stats['training_counter']?.toString() ?? '0';
              final bestRhythm = _formatDecimal(stats['best_rhythm']) ?? '0.00';

              return _buildProfileView(
                context,
                name,
                username,
                email,
                kmTotal,
                trainingCounter,
                bestRhythm,
                userData,
              );
            }

            // Estado inicial - cargar datos del usuario
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<UserBloc>().add(const LoadCurrentUser());
            });

            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6A00)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileView(
    BuildContext context,
    String name,
    String username,
    String email,
    String kmTotal,
    String trainingCounter,
    String bestRhythm,
    Map<String, dynamic> userData,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ProfileHeader(
                  name: name,
                  email: email.isNotEmpty ? email : '@$username',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _ProfileStatBox(value: kmTotal, label: 'km totales'),
                  const SizedBox(width: 16),
                  _ProfileStatBox(
                    value: trainingCounter,
                    label: 'Entrenamientos',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: _ProfileStatBox(
                  value: bestRhythm,
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
                  onPressed: () {
                    final userId = userData['id'];
                    print('Debug: userId = $userId');
                    print('Debug: userData = $userData');

                    if (userId != null) {
                      try {
                        print('Debug: Attempting to navigate to /edit-profile');
                        context.push(
                          '/edit-profile',
                          extra: {
                            'userId': userId.toString(),
                            'currentUserData': userData,
                          },
                        );
                        print('Debug: Navigation successful');
                      } catch (e) {
                        print('Error en navegación: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al abrir edición: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Error: No se pudo obtener el ID del usuario',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF23233B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(
                        color: Color(0xFFB0B0B0),
                        width: 2,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Editar Perfil',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Cerrar sesión y limpiar el stack de navegación usando GoRouter
                    context.go('/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 105, 2, 2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 255, 3, 3),
                        width: 2,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Cerrar sesion',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _formatDecimal(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toStringAsFixed(2);
    }

    if (value is String) {
      final numValue = double.tryParse(value);
      if (numValue != null) {
        return numValue.toStringAsFixed(2);
      }
    }

    return value.toString();
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
        border: Border.all(color: Colors.grey[600]!, width: 1),
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

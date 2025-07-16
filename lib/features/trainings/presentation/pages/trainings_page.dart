// features/trainings/presentation/pages/trainings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:runinsight/features/user/data/services/user_service.dart';
import '../bloc/trainings_bloc.dart';
import '../bloc/trainings_event.dart';
import '../bloc/trainings_state.dart';
import '../widgets/training_card.dart';

class TrainingsPage extends StatefulWidget {
  const TrainingsPage({Key? key}) : super(key: key);

  @override
  State<TrainingsPage> createState() => _TrainingsPageState();
}

class _TrainingsPageState extends State<TrainingsPage> {
  @override
  void initState() {
    super.initState();
    // No cargar automáticamente para evitar duplicados
    // Los entrenamientos se cargarán desde HomePage o cuando el usuario haga refresh
  }

  void _loadTrainings() {
    // Obtener el ID del usuario desde el servicio
    final userId = UserService.getUserId();
    if (userId != null) {
      context.read<TrainingsBloc>().add(LoadUserTrainings(userId));
    } else {
      print('⚠️ No se pudo obtener el ID del usuario');
      // En lugar de mostrar SnackBar, manejamos esto en el estado
      context.read<TrainingsBloc>().add(LoadUserTrainings(-1)); // ID inválido para manejar el error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050510), Color(0xFF0A0A20), Color(0xFF0C0C27)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: const Text(
                'Mis Entrenamientos',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadTrainings,
                ),
              ],
            ),
            Expanded(
              child: BlocConsumer<TrainingsBloc, TrainingsState>(
                listener: (context, state) {
                  // Removemos el SnackBar de error para evitar mensajes técnicos
                  // Los errores se manejan en la UI principal
                },
                builder: (context, state) {
                  // Cargar entrenamientos solo si el estado es inicial
                  if (state is TrainingsInitial) {
                    _loadTrainings();
                  }
                  
                  if (state is TrainingsLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Cargando entrenamientos...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is TrainingsError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.wifi_off,
                              color: Colors.orange,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No se pudieron cargar los entrenamientos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Column(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _loadTrainings,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    minimumSize: const Size(200, 48),
                                  ),
                                  icon: const Icon(Icons.refresh, color: Colors.white),
                                  label: const Text(
                                    'Reintentar',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.go('/training_in_progress');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    minimumSize: const Size(200, 48),
                                  ),
                                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                                  label: const Text(
                                    'Comenzar Nuevo Entrenamiento',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: () {
                                    context.go('/home');
                                  },
                                  icon: const Icon(Icons.home, color: Colors.grey),
                                  label: const Text(
                                    'Volver al Inicio',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is TrainingsLoaded) {
                    if (state.trainings.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.fitness_center,
                              color: Colors.orange,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '¡Bienvenido a RunInsight!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Aún no tienes entrenamientos registrados.\n¡Comienza tu primer entrenamiento ahora!',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.go('/training_in_progress');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              icon: const Icon(Icons.play_arrow, color: Colors.white),
                              label: const Text(
                                'Comenzar Entrenamiento',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        _loadTrainings();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.trainings.length,
                        itemBuilder: (context, index) {
                          final training = state.trainings[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TrainingCard(training: training),
                          );
                        },
                      ),
                    );
                  }

                  return const Center(
                    child: Text(
                      'Cargando entrenamientos...',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

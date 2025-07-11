// features/trainings/presentation/pages/trainings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    _loadTrainings();
  }

  void _loadTrainings() {
    // Obtener el ID del usuario desde el servicio
    final userId = UserService.getUserId();
    if (userId != null) {
      context.read<TrainingsBloc>().add(LoadUserTrainings(userId));
    } else {
      print('⚠️ No se pudo obtener el ID del usuario');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo identificar al usuario'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          'Mis Entrenamientos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTrainings,
          ),
        ],
      ),
      body: BlocConsumer<TrainingsBloc, TrainingsState>(
        listener: (context, state) {
          if (state is TrainingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TrainingsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            );
          }

          if (state is TrainingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar entrenamientos',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTrainings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      'Reintentar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
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
                      color: Colors.grey,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No tienes entrenamientos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Comienza un entrenamiento para verlo aquí',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
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
    );
  }
}

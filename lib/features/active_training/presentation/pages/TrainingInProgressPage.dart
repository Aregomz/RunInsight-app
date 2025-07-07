import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/active_training_bloc.dart';
import '../widgets/TrainingMetricsCard.dart';
import '../widgets/finish_training_button.dart';
import '../widgets/share_training_button.dart';

class TrainingInProgressPage extends StatelessWidget {
  const TrainingInProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C27),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: BlocBuilder<ActiveTrainingBloc, ActiveTrainingState>(
            builder: (context, state) {
              if (state is ActiveTrainingLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ActiveTrainingInProgress) {
                final session = state.session;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.circle, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Entrenamiento\nen curso',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            height: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    TrainingMetricsCard(
                      distanceKm: session.distanceKm,
                      pace: _formatDuration(session.duration),
                      heartRate: session.avgHeartRate,
                      calories: session.caloriesBurned,
                    ),
                    const Spacer(),
                    FinishTrainingButton(
                      onPressed: () {
                        context.read<ActiveTrainingBloc>().add(
                          FinishTrainingRequested(),
                        );
                      },
                    ),
                  ],
                );
              } else if (state is ActiveTrainingCompleted) {
                final summary = state.summary;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Resumen de entrenamiento',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TrainingMetricsCard(
                      distanceKm: summary.distanceKm,
                      pace: _formatDuration(summary.duration),
                      heartRate: summary.avgHeartRate,
                      calories: summary.caloriesBurned,
                    ),
                    const Spacer(),
                    ShareTrainingButton(
                      summaryWidget: TrainingMetricsCard(
                        distanceKm: summary.distanceKm,
                        pace: _formatDuration(summary.duration),
                        heartRate: summary.avgHeartRate,
                        calories: summary.caloriesBurned,
                      ),
                    ),
                  ],
                );
              } else {
                // Estado inicial: todo en cero y botón para comenzar
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.circle, color: Colors.grey, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Listo para\ncomenzar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            height: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    TrainingMetricsCard(
                      distanceKm: 0.0,
                      pace: _formatDuration(Duration.zero),
                      heartRate: 0,
                      calories: 0,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<ActiveTrainingBloc>().add(
                            StartTrainingRequested(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Comenzar entrenamiento',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  static String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

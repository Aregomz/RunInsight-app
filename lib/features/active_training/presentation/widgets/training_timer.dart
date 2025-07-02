// features/trainings/presentation/widgets/training_timer.dart
import 'package:flutter/material.dart';

class TrainingTimer extends StatelessWidget {
  final Duration duration;

  const TrainingTimer({super.key, required this.duration});

  @override
  Widget build(BuildContext context) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Column(
      children: [
        const Text('Tiempo', style: TextStyle(color: Colors.white54)),
        Text('$minutes:$seconds',
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white))
      ],
    );
  }
}

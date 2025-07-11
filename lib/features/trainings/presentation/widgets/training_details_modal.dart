// features/trainings/presentation/widgets/training_details_modal.dart
import 'package:flutter/material.dart';
import 'package:runinsight/features/trainings/domain/entities/training_entity.dart';
import 'package:go_router/go_router.dart';

class TrainingDetailsModal extends StatelessWidget {
  final TrainingEntity training;

  const TrainingDetailsModal({super.key, required this.training});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0C0C27),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('Fecha:', training.date.toString().split(' ')[0]),
            _buildRow('Distancia:', '${training.distanceKm.toStringAsFixed(2)} km'),
            _buildRow('Duración:', '${training.timeMinutes} min'),
            _buildRow('Ritmo:', '${training.rhythm.toStringAsFixed(1)} min/km'),
            _buildRow('Altitud:', '${training.altitude.toStringAsFixed(0)} m'),
            _buildRow('Tipo:', training.trainingType),
            _buildRow('Terreno:', training.terrainType),
            _buildRow('Clima:', training.weather),
            if (training.notes != null && training.notes!.isNotEmpty)
              _buildRow('Notas:', training.notes!),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    GoRouter.of(context).go('/home');
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6A00)),
                child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

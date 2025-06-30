// features/trainings/presentation/widgets/training_details_modal.dart
import 'package:flutter/material.dart';
import 'package:runinsight/features/trainings/domain/entities/training_entity.dart';

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
            _buildRow('Distancia:', '${training.kilometers.toStringAsFixed(2)} km'),
            _buildRow('Duración:', '${training.duration} min'),
            _buildRow('Ritmo:', training.pace),
            _buildRow('Calorías:', training.calories.toString()),
            _buildRow('Clima:', training.weather),
            _buildRow('Frecuencia cardiaca:', '${training.heartRate} bpm'),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
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

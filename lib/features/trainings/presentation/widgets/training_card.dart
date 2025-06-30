// features/trainings/presentation/widgets/training_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:runinsight/features/trainings/domain/entities/training_entity.dart';
import 'training_details_modal.dart';

class TrainingCard extends StatelessWidget {
  final TrainingEntity training;

  const TrainingCard({super.key, required this.training});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy').format(training.date);

    return Card(
      color: const Color(0xFF1C1C2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Text(
          dateStr,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${training.kilometers.toStringAsFixed(2)} km',
          style: const TextStyle(color: Colors.white70),
        ),
        onTap: () => showDialog(
          context: context,
          builder: (_) => TrainingDetailsModal(training: training),
        ),
      ),
    );
  }
}
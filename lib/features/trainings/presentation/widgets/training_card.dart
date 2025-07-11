// features/trainings/presentation/widgets/training_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/training_entity.dart';

class TrainingCard extends StatelessWidget {
  final TrainingEntity training;

  const TrainingCard({
    Key? key,
    required this.training,
  }) : super(key: key);

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${remainingMinutes}m';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  IconData _getTrainingTypeIcon(String trainingType) {
    switch (trainingType.toLowerCase()) {
      case 'easy run':
      case 'carrera fácil':
        return Icons.directions_run;
      case 'tempo run':
      case 'carrera tempo':
        return Icons.speed;
      case 'long run':
      case 'carrera larga':
        return Icons.timeline;
      case 'interval training':
      case 'entrenamiento por intervalos':
        return Icons.repeat;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getTrainingTypeColor(String trainingType) {
    switch (trainingType.toLowerCase()) {
      case 'easy run':
      case 'carrera fácil':
        return Colors.green;
      case 'tempo run':
      case 'carrera tempo':
        return Colors.orange;
      case 'long run':
      case 'carrera larga':
        return Colors.blue;
      case 'interval training':
      case 'entrenamiento por intervalos':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con fecha y tipo de entrenamiento
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getTrainingTypeIcon(training.trainingType),
                      color: _getTrainingTypeColor(training.trainingType),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      training.trainingType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatDate(training.date),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Métricas principales
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    icon: Icons.timer,
                    value: _formatDuration(training.timeMinutes),
                    label: 'Duración',
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    icon: Icons.straighten,
                    value: '${training.distanceKm.toStringAsFixed(1)} km',
                    label: 'Distancia',
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    icon: Icons.speed,
                    value: '${training.rhythm.toStringAsFixed(1)} min/km',
                    label: 'Ritmo',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Información adicional
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.terrain,
                    text: training.terrainType,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.wb_sunny,
                    text: training.weather,
                  ),
                ),
                if (training.altitude != 0)
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.height,
                      text: '${training.altitude.toStringAsFixed(0)}m',
                    ),
                  ),
              ],
            ),
            
            // Notas (si existen)
            if (training.notes != null && training.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.note,
                      color: Colors.blue,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        training.notes!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.orange,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.grey,
          size: 16,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

class TrainingMetricsCard extends StatelessWidget {
  final double distanceKm;
  final String pace;
  final int heartRate;
  final int calories;

  const TrainingMetricsCard({
    super.key,
    required this.distanceKm,
    required this.pace,
    required this.heartRate,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF6A00).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildCompactMetric('Distancia', '${distanceKm.toStringAsFixed(2)}', 'km', Icons.straighten)),
          _buildDivider(),
          Expanded(child: _buildCompactMetric('Ritmo', pace, 'min/km', Icons.speed)),
          _buildDivider(),
          Expanded(child: _buildCompactMetric('Frecuencia', '$heartRate', 'bpm', Icons.favorite)),
          _buildDivider(),
          Expanded(child: _buildCompactMetric('Calorías', '$calories', 'kcal', Icons.local_fire_department)),
        ],
      ),
    );
  }

  Widget _buildCompactMetric(String label, String value, String unit, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFFFF6A00),
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 10,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

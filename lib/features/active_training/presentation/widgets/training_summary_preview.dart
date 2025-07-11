import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

class TrainingSummaryPreview extends StatelessWidget {
  final Map<String, dynamic> trainingData;
  final ScreenshotController screenshotController;

  const TrainingSummaryPreview({
    super.key,
    required this.trainingData,
    required this.screenshotController,
  });

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Container(
        width: 300,
        height: 500,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B2565),
              Color(0xFF2D3748),
              Color(0xFF0C0C27),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.orange.withOpacity(0.5),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header con icono y título
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.fitness_center,
                      color: Colors.orange,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '¡Entrenamiento Completado!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Métricas principales
              Expanded(
                child: Column(
                  children: [
                    _buildMetricCard('Tiempo', _formatDuration(int.parse(trainingData['time_minutes'] ?? '0')), Icons.timer, Colors.blue),
                    const SizedBox(height: 12),
                    _buildMetricCard('Distancia', '${double.tryParse(trainingData['distance_km'] ?? '0')?.toStringAsFixed(2) ?? '0.00'} km', Icons.straighten, Colors.green),
                    const SizedBox(height: 12),
                    _buildMetricCard('Ritmo', '${double.tryParse(trainingData['rhythm'] ?? '0')?.toStringAsFixed(1) ?? '0.0'} min/km', Icons.speed, Colors.purple),
                    const SizedBox(height: 12),
                    _buildMetricCard('Altitud', '${double.tryParse(trainingData['altitude'] ?? '0')?.toStringAsFixed(0) ?? '0'} m', Icons.height, Colors.orange),
                  ],
                ),
              ),
              
              // Información adicional
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Tipo', trainingData['trainingType'] ?? 'Carrera'),
                    const SizedBox(height: 4),
                    _buildInfoRow('Terreno', trainingData['terrainType'] ?? 'Pavimento'),
                    const SizedBox(height: 4),
                    _buildInfoRow('Clima', trainingData['weather'] ?? 'No disponible'),
                    const SizedBox(height: 8),
                    Text(
                      'Fecha: ${trainingData['date'] ?? 'Hoy'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Logo de la app
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: const Text(
                  'RunInsight',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${remainingMinutes}m';
    }
  }
} 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TrainingSummaryPage extends StatelessWidget {
  final Map<String, dynamic> trainingData;

  const TrainingSummaryPage({
    super.key,
    required this.trainingData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C27),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Resumen del Entrenamiento',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40), // Balance del header
                ],
              ),
            ),
            
            // Contenido principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Tarjeta de resumen
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1B2565),
                            Color(0xFF2D3748),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Icono y título
                          const Icon(
                            Icons.fitness_center,
                            color: Colors.orange,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '¡Entrenamiento Completado!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Métricas principales
                          _buildMetricRow('Tiempo', _formatDuration(int.parse(trainingData['time_minutes'] ?? '0')), Icons.timer),
                          _buildMetricRow('Distancia', '${double.tryParse(trainingData['distance_km'] ?? '0')?.toStringAsFixed(2) ?? '0.00'} km', Icons.straighten),
                          _buildMetricRow('Ritmo', '${double.tryParse(trainingData['rhythm'] ?? '0')?.toStringAsFixed(1) ?? '0.0'} min/km', Icons.speed),
                          _buildMetricRow('Altitud', '${double.tryParse(trainingData['altitude'] ?? '0')?.toStringAsFixed(0) ?? '0'} m', Icons.height),
                          _buildMetricRow('Tipo', trainingData['trainingType'] ?? 'Carrera', Icons.category),
                          _buildMetricRow('Terreno', trainingData['terrainType'] ?? 'Pavimento', Icons.terrain),
                          _buildMetricRow('Clima', trainingData['weather'] ?? 'No disponible', Icons.cloud),
                          
                          if (trainingData['notes'] != null && trainingData['notes'].isNotEmpty && trainingData['notes'] != 'null') ...[
                            const SizedBox(height: 16),
                            _buildMetricRow('Notas', trainingData['notes'], Icons.note),
                          ],
                          
                          const SizedBox(height: 24),
                          
                          // Fecha
                          Text(
                            'Fecha: ${trainingData['date']}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Logo de la app
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'RunInsight',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Mensaje temporal
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.5)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue, size: 24),
                          SizedBox(height: 8),
                          Text(
                            'Funcionalidad de compartir en desarrollo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Próximamente podrás compartir tu entrenamiento en redes sociales',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Botón de volver al home
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/home'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Volver al Inicio',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
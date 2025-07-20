import 'package:flutter/material.dart';
import '../../data/services/offline_sync_service.dart';
import '../../data/models/offline_training_model.dart';

class OfflineTrainingsListWidget extends StatefulWidget {
  const OfflineTrainingsListWidget({super.key});

  @override
  State<OfflineTrainingsListWidget> createState() => _OfflineTrainingsListWidgetState();
}

class _OfflineTrainingsListWidgetState extends State<OfflineTrainingsListWidget> {
  final OfflineSyncService _syncService = OfflineSyncService();
  List<OfflineTrainingModel> _trainings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOfflineTrainings();
  }

  Future<void> _loadOfflineTrainings() async {
    try {
      final trainings = await _syncService.getOfflineTrainings();
      if (mounted) {
        setState(() {
          _trainings = trainings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteTraining(String trainingId) async {
    try {
      await _syncService.deleteOfflineTraining(trainingId);
      await _loadOfflineTrainings(); // Recargar lista
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entrenamiento eliminado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        color: Color(0xFF1C1C2E),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_trainings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: const Color(0xFF1C1C2E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.offline_bolt,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Entrenamientos Offline (${_trainings.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._trainings.map((training) => _buildTrainingItem(training)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingItem(OfflineTrainingModel training) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(training.syncStatus).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                training.statusIcon,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${training.distanceKm.toStringAsFixed(2)} km - ${training.timeMinutes} min',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Ritmo: ${training.rhythm.toStringAsFixed(2)} min/km',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteTraining(training.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar'),
                      ],
                    ),
                  ),
                ],
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip('Tipo', training.trainingType),
              const SizedBox(width: 8),
              _buildInfoChip('Terreno', training.terrainType),
              const SizedBox(width: 8),
              _buildInfoChip('Clima', training.weather),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            training.statusDescription,
            style: TextStyle(
              color: _getStatusColor(training.syncStatus),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (training.errorMessage != null) ...[
            const SizedBox(height: 4),
            Text(
              'Error: ${training.errorMessage}',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 11,
              ),
            ),
          ],
          if (training.retryCount > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Reintentos: ${training.retryCount}/3',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.pending:
        return Colors.orange;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.failed:
        return Colors.red;
    }
  }
} 
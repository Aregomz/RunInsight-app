import 'package:flutter/material.dart';
import '../../data/services/offline_sync_service.dart';
import '../../data/models/offline_training_model.dart';
import '../../../../core/services/connectivity_service.dart';

class OfflineSyncStatusWidget extends StatefulWidget {
  const OfflineSyncStatusWidget({super.key});

  @override
  State<OfflineSyncStatusWidget> createState() => _OfflineSyncStatusWidgetState();
}

class _OfflineSyncStatusWidgetState extends State<OfflineSyncStatusWidget> {
  final OfflineSyncService _syncService = OfflineSyncService();
  final ConnectivityService _connectivityService = ConnectivityService();
  
  Map<String, dynamic> _syncStats = {};
  bool _isLoading = true;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _loadSyncStats();
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    _connectivityService.connectionStatusStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
        
        // Si se restaura la conexión, intentar sincronizar
        if (isConnected) {
          _syncOfflineTrainings();
        }
      }
    });
  }

  Future<void> _loadSyncStats() async {
    try {
      final stats = await _syncService.getSyncStats();
      if (mounted) {
        setState(() {
          _syncStats = stats;
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

  Future<void> _syncOfflineTrainings() async {
    try {
      await _syncService.syncOfflineTrainings();
      await _loadSyncStats(); // Recargar estadísticas
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sincronización completada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en sincronización: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _retryFailedSyncs() async {
    try {
      await _syncService.retryFailedSyncs();
      await _loadSyncStats(); // Recargar estadísticas
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reintentos completados'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en reintentos: $e'),
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
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text(
                'Cargando estado offline...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    final total = _syncStats['total'] ?? 0;
    final pending = _syncStats['pending'] ?? 0;
    final syncing = _syncStats['syncing'] ?? 0;
    final synced = _syncStats['synced'] ?? 0;
    final failed = _syncStats['failed'] ?? 0;
    final canRetry = _syncStats['canRetry'] ?? 0;

    // Solo mostrar si hay entrenamientos offline
    if (total == 0) {
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
                Icon(
                  _isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: _isConnected ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sincronización Offline',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _isConnected ? 'Conectado' : 'Sin conexión',
                        style: TextStyle(
                          color: _isConnected ? Colors.green : Colors.orange,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isConnected && (pending > 0 || failed > 0))
                  IconButton(
                    onPressed: _syncOfflineTrainings,
                    icon: const Icon(Icons.sync, color: Colors.blue),
                    tooltip: 'Sincronizar',
                  ),
                if (canRetry > 0)
                  IconButton(
                    onPressed: _retryFailedSyncs,
                    icon: const Icon(Icons.refresh, color: Colors.orange),
                    tooltip: 'Reintentar fallidos',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatsRow('Total', total, Colors.white),
            if (pending > 0) _buildStatsRow('⏳ Pendientes', pending, Colors.orange),
            if (syncing > 0) _buildStatsRow('🔄 Sincronizando', syncing, Colors.blue),
            if (synced > 0) _buildStatsRow('✅ Sincronizados', synced, Colors.green),
            if (failed > 0) _buildStatsRow('❌ Fallidos', failed, Colors.red),
            if (canRetry > 0) _buildStatsRow('🔄 Pueden reintentar', canRetry, Colors.orange),
            
            // Barra de progreso
            if (total > 0) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: synced / total,
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  failed > 0 ? Colors.orange : Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${((synced / total) * 100).toStringAsFixed(1)}% sincronizado',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
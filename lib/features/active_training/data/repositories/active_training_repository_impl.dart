import '../../domain/entities/active_training_session.dart';
import '../../domain/repositories/active_training_repository.dart';
import '../datasources/active_training_remote_datasource.dart';
import '../models/active_training_request_model.dart';
import '../models/offline_training_model.dart';
import '../services/offline_sync_service.dart';
import '../../../../core/services/connectivity_service.dart';

class ActiveTrainingRepositoryImpl implements ActiveTrainingRepository {
  final ActiveTrainingRemoteDatasource remoteDatasource;
  final OfflineSyncService _offlineSyncService = OfflineSyncService();
  final ConnectivityService _connectivityService = ConnectivityService();
  
  ActiveTrainingRepositoryImpl({ActiveTrainingRemoteDatasource? remoteDatasource})
      : remoteDatasource = remoteDatasource ?? ActiveTrainingRemoteDatasourceImpl();

  @override
  Future<void> saveActiveTraining(ActiveTrainingSession session) async {
    try {
      final request = ActiveTrainingRequestModel(
        timeMinutes: session.timeMinutes,
        distanceKm: session.distanceKm,
        rhythm: session.rhythm,
        date: session.date,
        altitude: session.altitude,
        notes: session.notes,
        trainingType: session.trainingType,
        terrainType: session.terrainType,
        weather: session.weather,
      );

      // Verificar conectividad
      if (_connectivityService.isConnected) {
        print('🌐 Conectado - Enviando entrenamiento al servidor...');
        try {
          await remoteDatasource.sendActiveTraining(request);
          print('✅ Entrenamiento enviado exitosamente al servidor');
        } catch (e) {
          print('❌ Error al enviar al servidor, guardando offline: $e');
          // Si falla el envío al servidor, guardar offline
          await _saveOffline(request);
        }
      } else {
        print('📱 Sin conexión - Guardando entrenamiento offline...');
        await _saveOffline(request);
      }
    } catch (e) {
      print('❌ Error al guardar entrenamiento: $e');
      // En caso de error, intentar guardar offline como respaldo
      try {
        final request = ActiveTrainingRequestModel(
          timeMinutes: session.timeMinutes,
          distanceKm: session.distanceKm,
          rhythm: session.rhythm,
          date: session.date,
          altitude: session.altitude,
          notes: session.notes,
          trainingType: session.trainingType,
          terrainType: session.terrainType,
          weather: session.weather,
        );
        await _saveOffline(request);
      } catch (offlineError) {
        print('❌ Error crítico: No se pudo guardar ni online ni offline: $offlineError');
        rethrow;
      }
    }
  }

  /// Guardar entrenamiento offline
  Future<void> _saveOffline(ActiveTrainingRequestModel request) async {
    try {
      final offlineTraining = OfflineTrainingModel.fromActiveTraining(request);
      await _offlineSyncService.saveOfflineTraining(offlineTraining);
      print('💾 Entrenamiento guardado offline: ${offlineTraining.id}');
    } catch (e) {
      print('❌ Error al guardar offline: $e');
      rethrow;
    }
  }

  /// Obtener entrenamientos offline
  Future<List<OfflineTrainingModel>> getOfflineTrainings() async {
    return await _offlineSyncService.getOfflineTrainings();
  }

  /// Sincronizar entrenamientos offline
  Future<void> syncOfflineTrainings() async {
    await _offlineSyncService.syncOfflineTrainings();
  }

  /// Obtener estadísticas de sincronización
  Future<Map<String, dynamic>> getSyncStats() async {
    return await _offlineSyncService.getSyncStats();
  }
} 
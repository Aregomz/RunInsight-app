import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/offline_training_model.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';

class OfflineSyncService {
  static const String _offlineTrainingsKey = 'offline_trainings';
  static const String _syncQueueKey = 'sync_queue';
  
  final ConnectivityService _connectivityService = ConnectivityService();
  
  /// Guardar entrenamiento offline
  Future<void> saveOfflineTraining(OfflineTrainingModel training) async {
    try {
      print('💾 Guardando entrenamiento offline: ${training.id}');
      
      final prefs = await SharedPreferences.getInstance();
      final offlineTrainings = await _getOfflineTrainings();
      
      // Agregar o actualizar el entrenamiento
      final existingIndex = offlineTrainings.indexWhere((t) => t.id == training.id);
      if (existingIndex >= 0) {
        offlineTrainings[existingIndex] = training;
      } else {
        offlineTrainings.add(training);
      }
      
      // Guardar en SharedPreferences
      final trainingsJson = offlineTrainings.map((t) => t.toJson()).toList();
      await prefs.setString(_offlineTrainingsKey, json.encode(trainingsJson));
      
      print('✅ Entrenamiento offline guardado: ${training.id}');
      
      // Intentar sincronizar si hay conexión
      if (_connectivityService.isConnected) {
        await syncOfflineTrainings();
      }
    } catch (e) {
      print('❌ Error al guardar entrenamiento offline: $e');
    }
  }
  
  /// Obtener todos los entrenamientos offline
  Future<List<OfflineTrainingModel>> getOfflineTrainings() async {
    return await _getOfflineTrainings();
  }
  
  /// Obtener entrenamientos que necesitan sincronización
  Future<List<OfflineTrainingModel>> getPendingSyncTrainings() async {
    final trainings = await _getOfflineTrainings();
    return trainings.where((t) => t.needsSync).toList();
  }
  
  /// Sincronizar entrenamientos offline
  Future<void> syncOfflineTrainings() async {
    try {
      print('🔄 Iniciando sincronización de entrenamientos offline...');
      
      if (!_connectivityService.isConnected) {
        print('⚠️ Sin conexión a internet, sincronización pospuesta');
        return;
      }
      
      final pendingTrainings = await getPendingSyncTrainings();
      if (pendingTrainings.isEmpty) {
        print('✅ No hay entrenamientos pendientes de sincronización');
        return;
      }
      
      print('📤 Sincronizando ${pendingTrainings.length} entrenamientos...');
      
      for (final training in pendingTrainings) {
        await _syncSingleTraining(training);
      }
      
      print('✅ Sincronización completada');
    } catch (e) {
      print('❌ Error durante la sincronización: $e');
    }
  }
  
  /// Sincronizar un entrenamiento específico
  Future<bool> _syncSingleTraining(OfflineTrainingModel training) async {
    try {
      print('🔄 Sincronizando entrenamiento: ${training.id}');
      
      // Marcar como sincronizando
      final updatedTraining = training.copyWith(syncStatus: SyncStatus.syncing);
      await saveOfflineTraining(updatedTraining);
      
      // Enviar al servidor
      final response = await DioClient.post(
        ApiEndpoints.finishTraining,
        data: training.toActiveTrainingJson(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Sincronización exitosa
        final syncedTraining = training.copyWith(
          syncStatus: SyncStatus.synced,
          syncedAt: DateTime.now(),
          serverId: response.data['id']?.toString(),
          errorMessage: null,
        );
        
        await saveOfflineTraining(syncedTraining);
        print('✅ Entrenamiento sincronizado: ${training.id}');
        return true;
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al sincronizar entrenamiento ${training.id}: $e');
      
      // Marcar como fallido
      final failedTraining = training.copyWith(
        syncStatus: SyncStatus.failed,
        errorMessage: e.toString(),
        retryCount: training.retryCount + 1,
      );
      
      await saveOfflineTraining(failedTraining);
      return false;
    }
  }
  
  /// Reintentar sincronización de entrenamientos fallidos
  Future<void> retryFailedSyncs() async {
    try {
      print('🔄 Reintentando sincronización de entrenamientos fallidos...');
      
      final failedTrainings = await getOfflineTrainings();
      final retryableTrainings = failedTrainings.where((t) => t.canRetry).toList();
      
      if (retryableTrainings.isEmpty) {
        print('✅ No hay entrenamientos para reintentar');
        return;
      }
      
      print('🔄 Reintentando ${retryableTrainings.length} entrenamientos...');
      
      for (final training in retryableTrainings) {
        await _syncSingleTraining(training);
      }
    } catch (e) {
      print('❌ Error al reintentar sincronización: $e');
    }
  }
  
  /// Limpiar entrenamientos sincronizados antiguos
  Future<void> cleanupSyncedTrainings({int daysToKeep = 7}) async {
    try {
      print('🧹 Limpiando entrenamientos sincronizados antiguos...');
      
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final allTrainings = await _getOfflineTrainings();
      
      final trainingsToKeep = allTrainings.where((training) {
        // Mantener entrenamientos no sincronizados
        if (training.syncStatus != SyncStatus.synced) return true;
        
        // Mantener entrenamientos sincronizados recientes
        if (training.syncedAt != null && training.syncedAt!.isAfter(cutoffDate)) {
          return true;
        }
        
        return false;
      }).toList();
      
      // Guardar solo los entrenamientos que se deben mantener
      final prefs = await SharedPreferences.getInstance();
      final trainingsJson = trainingsToKeep.map((t) => t.toJson()).toList();
      await prefs.setString(_offlineTrainingsKey, json.encode(trainingsJson));
      
      final removedCount = allTrainings.length - trainingsToKeep.length;
      print('✅ Limpieza completada: $removedCount entrenamientos removidos');
    } catch (e) {
      print('❌ Error durante la limpieza: $e');
    }
  }
  
  /// Obtener estadísticas de sincronización
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final trainings = await _getOfflineTrainings();
      
      final stats = {
        'total': trainings.length,
        'pending': trainings.where((t) => t.syncStatus == SyncStatus.pending).length,
        'syncing': trainings.where((t) => t.syncStatus == SyncStatus.syncing).length,
        'synced': trainings.where((t) => t.syncStatus == SyncStatus.synced).length,
        'failed': trainings.where((t) => t.syncStatus == SyncStatus.failed).length,
        'canRetry': trainings.where((t) => t.canRetry).length,
      };
      
      return stats;
    } catch (e) {
      return {
        'total': 0,
        'pending': 0,
        'syncing': 0,
        'synced': 0,
        'failed': 0,
        'canRetry': 0,
      };
    }
  }
  
  /// Método privado para obtener entrenamientos offline
  Future<List<OfflineTrainingModel>> _getOfflineTrainings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trainingsString = prefs.getString(_offlineTrainingsKey);
      
      if (trainingsString == null || trainingsString.isEmpty) {
        return [];
      }
      
      final trainingsJson = json.decode(trainingsString) as List;
      return trainingsJson
          .map((json) => OfflineTrainingModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error al cargar entrenamientos offline: $e');
      return [];
    }
  }
  
  /// Eliminar entrenamiento offline
  Future<void> deleteOfflineTraining(String trainingId) async {
    try {
      print('🗑️ Eliminando entrenamiento offline: $trainingId');
      
      final trainings = await _getOfflineTrainings();
      trainings.removeWhere((t) => t.id == trainingId);
      
      final prefs = await SharedPreferences.getInstance();
      final trainingsJson = trainings.map((t) => t.toJson()).toList();
      await prefs.setString(_offlineTrainingsKey, json.encode(trainingsJson));
      
      print('✅ Entrenamiento offline eliminado: $trainingId');
    } catch (e) {
      print('❌ Error al eliminar entrenamiento offline: $e');
    }
  }
} 
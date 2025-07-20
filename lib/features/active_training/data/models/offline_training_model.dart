import 'package:uuid/uuid.dart';

enum SyncStatus {
  pending,    // Pendiente de sincronizar
  syncing,    // Sincronizando actualmente
  synced,     // Sincronizado exitosamente
  failed,     // Error al sincronizar
}

class OfflineTrainingModel {
  final String id;           // ID único local
  final int timeMinutes;
  final double distanceKm;
  final double rhythm;
  final String date;
  final double altitude;
  final String? notes;
  final String trainingType;
  final String terrainType;
  final String weather;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime? syncedAt;
  final String? serverId;    // ID del servidor después de sincronizar
  final String? errorMessage; // Mensaje de error si falló la sincronización
  final int retryCount;      // Número de intentos de sincronización

  OfflineTrainingModel({
    String? id,
    required this.timeMinutes,
    required this.distanceKm,
    required this.rhythm,
    required this.date,
    required this.altitude,
    this.notes,
    required this.trainingType,
    required this.terrainType,
    required this.weather,
    this.syncStatus = SyncStatus.pending,
    DateTime? createdAt,
    this.syncedAt,
    this.serverId,
    this.errorMessage,
    this.retryCount = 0,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();

  // Crear desde ActiveTrainingRequestModel
  factory OfflineTrainingModel.fromActiveTraining(dynamic activeTraining) {
    return OfflineTrainingModel(
      timeMinutes: activeTraining.timeMinutes,
      distanceKm: activeTraining.distanceKm,
      rhythm: activeTraining.rhythm,
      date: activeTraining.date,
      altitude: activeTraining.altitude,
      notes: activeTraining.notes,
      trainingType: activeTraining.trainingType,
      terrainType: activeTraining.terrainType,
      weather: activeTraining.weather,
    );
  }

  // Convertir a ActiveTrainingRequestModel
  Map<String, dynamic> toActiveTrainingJson() => {
    'time_minutes': timeMinutes,
    'distance_km': distanceKm,
    'rhythm': rhythm,
    'date': date,
    'altitude': altitude,
    if (notes != null) 'notes': notes,
    'trainingType': trainingType,
    'terrainType': terrainType,
    'weather': weather,
  };

  // Crear copia con estado actualizado
  OfflineTrainingModel copyWith({
    String? id,
    int? timeMinutes,
    double? distanceKm,
    double? rhythm,
    String? date,
    double? altitude,
    String? notes,
    String? trainingType,
    String? terrainType,
    String? weather,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? syncedAt,
    String? serverId,
    String? errorMessage,
    int? retryCount,
  }) {
    return OfflineTrainingModel(
      id: id ?? this.id,
      timeMinutes: timeMinutes ?? this.timeMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      rhythm: rhythm ?? this.rhythm,
      date: date ?? this.date,
      altitude: altitude ?? this.altitude,
      notes: notes ?? this.notes,
      trainingType: trainingType ?? this.trainingType,
      terrainType: terrainType ?? this.terrainType,
      weather: weather ?? this.weather,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      serverId: serverId ?? this.serverId,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  // Convertir a JSON para almacenamiento local
  Map<String, dynamic> toJson() => {
    'id': id,
    'timeMinutes': timeMinutes,
    'distanceKm': distanceKm,
    'rhythm': rhythm,
    'date': date,
    'altitude': altitude,
    'notes': notes,
    'trainingType': trainingType,
    'terrainType': terrainType,
    'weather': weather,
    'syncStatus': syncStatus.index,
    'createdAt': createdAt.toIso8601String(),
    'syncedAt': syncedAt?.toIso8601String(),
    'serverId': serverId,
    'errorMessage': errorMessage,
    'retryCount': retryCount,
  };

  // Crear desde JSON
  factory OfflineTrainingModel.fromJson(Map<String, dynamic> json) {
    return OfflineTrainingModel(
      id: json['id'],
      timeMinutes: json['timeMinutes'],
      distanceKm: json['distanceKm'].toDouble(),
      rhythm: json['rhythm'].toDouble(),
      date: json['date'],
      altitude: json['altitude'].toDouble(),
      notes: json['notes'],
      trainingType: json['trainingType'],
      terrainType: json['terrainType'],
      weather: json['weather'],
      syncStatus: SyncStatus.values[json['syncStatus']],
      createdAt: DateTime.parse(json['createdAt']),
      syncedAt: json['syncedAt'] != null ? DateTime.parse(json['syncedAt']) : null,
      serverId: json['serverId'],
      errorMessage: json['errorMessage'],
      retryCount: json['retryCount'] ?? 0,
    );
  }

  // Verificar si necesita sincronización
  bool get needsSync => syncStatus == SyncStatus.pending || syncStatus == SyncStatus.failed;

  // Verificar si puede reintentar sincronización
  bool get canRetry => syncStatus == SyncStatus.failed && retryCount < 3;

  // Obtener descripción del estado
  String get statusDescription {
    switch (syncStatus) {
      case SyncStatus.pending:
        return 'Pendiente de sincronizar';
      case SyncStatus.syncing:
        return 'Sincronizando...';
      case SyncStatus.synced:
        return 'Sincronizado';
      case SyncStatus.failed:
        return 'Error al sincronizar';
    }
  }

  // Obtener icono del estado
  String get statusIcon {
    switch (syncStatus) {
      case SyncStatus.pending:
        return '⏳';
      case SyncStatus.syncing:
        return '🔄';
      case SyncStatus.synced:
        return '✅';
      case SyncStatus.failed:
        return '❌';
    }
  }
} 
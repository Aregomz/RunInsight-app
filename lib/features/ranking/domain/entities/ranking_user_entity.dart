// features/ranking/domain/entities/ranking_user_entity.dart

class RankingUserEntity {
  final String id;
  final String name;
  final int trainings;
  final double totalKm;

  const RankingUserEntity({
    required this.id,
    required this.name,
    required this.trainings,
    required this.totalKm,
  });

  /// Calcula el promedio de km por entrenamiento
  double get avgKmPerTraining => trainings == 0 ? 0 : totalKm / trainings;
}

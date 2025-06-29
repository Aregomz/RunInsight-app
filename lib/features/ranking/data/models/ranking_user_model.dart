// features/ranking/data/models/ranking_user_model.dart
import 'package:runinsight/features/ranking/domain/entities/ranking_user_entity.dart';

class RankingUserModel extends RankingUserEntity {
  const RankingUserModel({
    required super.id,
    required super.name,
    required double totalKm,
    required super.trainings,
  }) : super(totalKm: totalKm);

  factory RankingUserModel.fromJson(Map<String, dynamic> json) {
    return RankingUserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      totalKm: (json['kilometers'] as num).toDouble(),
      trainings: json['trainings'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'kilometers': totalKm,
      'trainings': trainings,
    };
  }

  double get averageKmPerTraining =>
      trainings == 0 ? 0.0 : totalKm / trainings;
}

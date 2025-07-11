// features/ranking/data/models/ranking_user_model.dart
import 'package:runinsight/features/ranking/domain/entities/ranking_user_entity.dart';

class RankingUserModel extends RankingUserEntity {
  const RankingUserModel({
    required super.id,
    required super.name,
    required super.totalKm,
    required super.trainings,
  });

  factory RankingUserModel.fromJson(Map<String, dynamic> json) {
    return RankingUserModel(
      id: json['id'].toString(),
      name: json['username'] as String,
      totalKm: (json['stats']['km_total'] as num).toDouble(),
      trainings: json['stats']['training_counter'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': name,
      'stats': {
        'km_total': totalKm,
        'training_counter': trainings,
      },
    };
  }

  double get averageKmPerTraining =>
      trainings == 0 ? 0.0 : totalKm / trainings;
}

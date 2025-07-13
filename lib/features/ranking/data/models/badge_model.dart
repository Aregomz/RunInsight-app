// features/ranking/data/models/badge_model.dart
import '../../domain/entities/badge_entity.dart';

class BadgeModel extends BadgeEntity {
  BadgeModel({
    required super.id,
    required super.name,
    required super.description,
    required super.urlIcon,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      urlIcon: json['url_icon'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'url_icon': urlIcon,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 
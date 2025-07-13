// features/ranking/domain/entities/badge_entity.dart
class BadgeEntity {
  final int id;
  final String name;
  final String description;
  final String urlIcon;
  final DateTime createdAt;
  final DateTime updatedAt;

  BadgeEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.urlIcon,
    required this.createdAt,
    required this.updatedAt,
  });
} 
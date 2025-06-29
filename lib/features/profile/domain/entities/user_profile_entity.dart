// features/profile/domain/entities/user_profile_entity.dart
class UserProfileEntity {
  final String username;
  final String fullName;
  final int heightCm;
  final double weightKg;
  final double bestPace;
  final double totalKm;
  final int totalWorkouts;

  UserProfileEntity({
    required this.username,
    required this.fullName,
    required this.heightCm,
    required this.weightKg,
    required this.bestPace,
    required this.totalKm,
    required this.totalWorkouts,
  });
}
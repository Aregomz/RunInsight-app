// features/profile/data/models/profile_update_model.dart
class ProfileUpdateModel {
  final double weight;
  final int height;
  final String experience;

  ProfileUpdateModel({
    required this.weight,
    required this.height,
    required this.experience,
  });

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'height': height,
      'experience': experience,
    };
  }

  factory ProfileUpdateModel.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateModel(
      weight: (json['weight'] as num).toDouble(),
      height: json['height'] as int,
      experience: json['experience'] as String,
    );
  }
} 
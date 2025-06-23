class UserEntity {
  final String name;
  final String email;
  final String username;
  final DateTime birthDate;
  final String gender;
  final String password;
  final double weight;
  final int height;

  const UserEntity({
    required this.name,
    required this.email,
    required this.username,
    required this.birthDate,
    required this.gender,
    required this.password,
    required this.weight,
    required this.height,
  });
}

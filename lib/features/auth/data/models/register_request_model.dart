class RegisterRequestModel {
  final String name;
  final String email;
  final String username;
  final String password;
  final String? gender;
  final String? birthdate;
  final String? expLevel;
  final double? weight;
  final int? height;

  RegisterRequestModel({
    required this.name,
    required this.email,
    required this.username,
    required this.password,
    this.gender,
    this.birthdate,
    this.expLevel,
    this.weight,
    this.height,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'username': username,
      'password': password,
    };

    if (gender != null) data['gender'] = gender;
    if (birthdate != null) data['birthdate'] = birthdate;
    if (expLevel != null || weight != null || height != null) {
      data['user_stats'] = {
        if (expLevel != null) 'exp_level': expLevel,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
      };
    }

    return data;
  }

  // Método para crear un modelo con formato mínimo (solo email y password)
  Map<String, dynamic> toMinimalJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  // Método para crear un modelo con formato simple (sin datos opcionales)
  Map<String, dynamic> toSimpleJson() {
    return {
      'name': name,
      'email': email,
      'username': username,
      'password': password,
      if (gender != null) 'gender': gender,
    };
  }

  static String formatBirthDateFromAge(String age) {
    int ageInt = int.tryParse(age) ?? 25;
    DateTime now = DateTime.now();
    DateTime birthDate = now.subtract(Duration(days: ageInt * 365));
    return '${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';
  }
} 
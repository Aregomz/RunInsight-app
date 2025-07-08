class AuthResponseModel {
  final String? token;
  final String? accessToken;
  final UserModel? user;
  final String? message;
  final String? error;

  AuthResponseModel({
    this.token,
    this.accessToken,
    this.user,
    this.message,
    this.error,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] ?? json['access_token'],
      accessToken: json['access_token'] ?? json['token'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      message: json['message'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'access_token': accessToken,
      'user': user?.toJson(),
      'message': message,
      'error': error,
    };
  }
}

class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? username;
  final int? rolesId;
  final String? token;
  final String? birthdate;
  final double? weight;
  final double? height;
  final int? genderId;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.username,
    this.rolesId,
    this.token,
    this.birthdate,
    this.weight,
    this.height,
    this.genderId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      username: json['username'],
      rolesId: json['rolesId'],
      token: json['token'],
      birthdate: json['birthdate'],
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      genderId: json['genderId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'rolesId': rolesId,
      'token': token,
      'birthdate': birthdate,
      'weight': weight,
      'height': height,
      'genderId': genderId,
    };
  }
} 
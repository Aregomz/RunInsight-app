import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> registerUser(UserEntity user);
  Future<void> loginUser(String email, String password);
}

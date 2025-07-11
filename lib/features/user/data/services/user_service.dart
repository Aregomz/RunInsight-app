import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_endpoints.dart';

class UserService {
  // static const String _baseUrl =
  //     'https://api-gateway-runinsight-production.up.railway.app';

  // Token de autenticación y datos del usuario
  static String? _authToken;
  static Map<String, dynamic>? _userData;

  // Inicializar el token desde shared_preferences
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      _userData = json.decode(userDataString);
    }
  }

  // Obtener el token actual (en memoria)
  static String? getAuthToken() => _authToken;

  // Obtener el ID del usuario actual
  static int? getUserId() {
    if (_userData != null && _userData!.containsKey('id')) {
      return _userData!['id'] as int;
    }
    return null;
  }

  // Establecer el token y datos del usuario después del login exitoso
  static Future<void> setAuthToken(String token, Map<String, dynamic> userData) async {
    _authToken = token;
    _userData = userData;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', json.encode(userData));
    print('✅ Token guardado: $token');
    print('✅ Datos mínimos guardados: $userData');
    print('🔑 Token disponible para API: $token');
  }

  // Obtener datos del usuario actual usando el endpoint /users/{id}
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      if (_authToken == null || _userData == null) {
        throw Exception(
          'No hay token o datos del usuario. Debes hacer login primero.',
        );
      }

      final userId = _userData!['id'];
      print('🔄 Obteniendo datos del usuario ID: $userId desde la API');
      print('🔑 Token disponible: $_authToken');

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
          // Probar diferentes formatos de autorización
          'X-Auth-Token': '$_authToken',
          'token': '$_authToken',
        },
      );

      print('📡 Código de respuesta getCurrentUser: ${response.statusCode}');
      print('📡 Cuerpo de respuesta: ${response.body}');
      print('🔑 Headers enviados: Authorization: Bearer $_authToken');
      print('🔑 Todos los headers: ${response.request?.headers}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Datos del usuario obtenidos de la API: $data');

        // La API devuelve los datos dentro de un objeto 'user'
        final userData = data['user'] ?? data;

        print('🔍 Campo username de la API: ${userData['username']}');
        print('🔍 Campo name de la API: ${userData['name']}');
        print('🔍 Campo email de la API: ${userData['email']}');
        print('🔍 Campo stats de la API: ${userData['stats']}');

        return userData;
      } else {
        throw Exception(
          'Error al obtener usuario: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error al obtener usuario de la API: $e');
      throw Exception(
        'No se pudieron obtener los datos reales del usuario: $e',
      );
    }
  }

  // Obtener datos del usuario por email (no disponible en esta API)
  static Future<Map<String, dynamic>> getUserByEmail(String email) async {
    throw Exception('Este endpoint no está disponible en la API actual');
  }

  // Obtener perfil completo del usuario (no disponible en esta API)
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    throw Exception('Este endpoint no está disponible en la API actual');
  }

  // Limpiar datos al cerrar sesión
  static Future<void> clearUserData() async {
    _authToken = null;
    _userData = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    print('✅ Datos del usuario limpiados');
  }

  // Generar link de invitación para agregar amigos
  static String generateInvitationLink() {
    final userId = getUserId();
    if (userId == null) {
      throw Exception('No se puede generar el link: usuario no autenticado');
    }
    
    // Generar un link que incluya el ID del usuario
    // Este link puede ser compartido para que otros usuarios se agreguen como amigos
    // Usar scheme personalizado para abrir directamente la app
    return 'runinsight://invite/$userId';
  }



  // Obtener el nombre del usuario actual para mostrar en el link
  static String? getCurrentUserName() {
    if (_userData != null && _userData!.containsKey('username')) {
      return _userData!['username'] as String;
    }
    return null;
  }
}

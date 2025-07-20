import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response_model.dart';

class AuthPersistenceService {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _loginTimestampKey = 'login_timestamp';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _isLoggedInKey = 'is_logged_in';
  
  /// Guarda los datos de autenticación de manera persistente
  static Future<void> saveAuthData(AuthResponseModel authResponse) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      
      // Extraer token (puede venir en diferentes campos)
      final token = authResponse.token ?? 
                   authResponse.accessToken ?? 
                   authResponse.user?.token;
      
      if (token == null) {
        throw Exception('No se recibió token de autenticación');
      }
      
      // Preparar datos del usuario
      final userData = {
        'id': authResponse.user?.id,
        'email': authResponse.user?.email,
        'username': authResponse.user?.username,
        'name': authResponse.user?.name,
        'rolesId': authResponse.user?.rolesId,
        'token': token,
        'createdAt': now.toIso8601String(),
      };
      
      // Guardar datos
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userDataKey, json.encode(userData));
      await prefs.setString(_loginTimestampKey, now.toIso8601String());
      await prefs.setBool(_isLoggedInKey, true);
      
      // Por ahora, asumimos que el token no expira (o expira en 30 días)
      // En el futuro, si la API devuelve expiresIn, se puede agregar aquí
      final defaultExpiryDate = now.add(const Duration(days: 30));
      await prefs.setString(_tokenExpiryKey, defaultExpiryDate.toIso8601String());
      
      print('✅ Datos de autenticación guardados persistentemente');
      print('🔑 Token: ${token.substring(0, 20)}...');
      print('👤 Usuario ID: ${userData['id']}');
    } catch (e) {
      print('❌ Error al guardar datos de autenticación: $e');
      rethrow;
    }
  }
  
  /// Carga los datos de autenticación guardados
  static Future<Map<String, dynamic>?> loadAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Verificar si hay datos guardados
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      if (!isLoggedIn) {
        print('🔍 No hay sesión guardada');
        return null;
      }
      
      // Cargar token
      final token = prefs.getString(_tokenKey);
      if (token == null) {
        print('🔍 No hay token guardado');
        await _clearAuthData();
        return null;
      }
      
      // Verificar expiración del token
      final expiryString = prefs.getString(_tokenExpiryKey);
      if (expiryString != null) {
        final expiryDate = DateTime.parse(expiryString);
        final now = DateTime.now();
        
        if (now.isAfter(expiryDate)) {
          print('⏰ Token expirado, limpiando datos');
          await _clearAuthData();
          return null;
        }
      }
      
      // Cargar datos del usuario
      final userDataString = prefs.getString(_userDataKey);
      if (userDataString == null) {
        print('🔍 No hay datos de usuario guardados');
        await _clearAuthData();
        return null;
      }
      
      final userData = json.decode(userDataString) as Map<String, dynamic>;
      
      print('✅ Datos de autenticación cargados');
      print('🔑 Token: ${token.substring(0, 20)}...');
      print('👤 Usuario ID: ${userData['id']}');
      
      return {
        'token': token,
        'userData': userData,
        'isLoggedIn': true,
      };
    } catch (e) {
      print('❌ Error al cargar datos de autenticación: $e');
      await _clearAuthData();
      return null;
    }
  }
  
  /// Verifica si el usuario está autenticado
  static Future<bool> isUserLoggedIn() async {
    try {
      final authData = await loadAuthData();
      return authData != null;
    } catch (e) {
      return false;
    }
  }
  
  /// Obtiene el token actual
  static Future<String?> getCurrentToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }
  
  /// Obtiene los datos del usuario actual
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);
      if (userDataString != null) {
        return json.decode(userDataString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Limpia todos los datos de autenticación
  static Future<void> clearAuthData() async {
    await _clearAuthData();
  }
  
  /// Método privado para limpiar datos
  static Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userDataKey);
      await prefs.remove(_loginTimestampKey);
      await prefs.remove(_tokenExpiryKey);
      await prefs.setBool(_isLoggedInKey, false);
      print('✅ Datos de autenticación limpiados');
    } catch (e) {
      print('❌ Error al limpiar datos de autenticación: $e');
    }
  }
  
  /// Actualiza solo los datos del usuario (sin cambiar el token)
  static Future<void> updateUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDataKey, json.encode(userData));
      print('✅ Datos del usuario actualizados');
    } catch (e) {
      print('❌ Error al actualizar datos del usuario: $e');
    }
  }
  
  /// Obtiene información sobre la sesión
  static Future<Map<String, dynamic>> getSessionInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginTimestamp = prefs.getString(_loginTimestampKey);
      final expiryString = prefs.getString(_tokenExpiryKey);
      
      return {
        'isLoggedIn': prefs.getBool(_isLoggedInKey) ?? false,
        'loginTimestamp': loginTimestamp,
        'expiryTimestamp': expiryString,
        'hasToken': prefs.getString(_tokenKey) != null,
        'hasUserData': prefs.getString(_userDataKey) != null,
      };
    } catch (e) {
      return {
        'isLoggedIn': false,
        'loginTimestamp': null,
        'expiryTimestamp': null,
        'hasToken': false,
        'hasUserData': false,
      };
    }
  }
} 
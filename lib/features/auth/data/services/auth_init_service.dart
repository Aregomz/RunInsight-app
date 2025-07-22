import '../services/auth_persistence_service.dart';
import '../../../user/data/services/user_service.dart';
import '../../../active_training/data/services/training_state_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInitService {
  /// Inicializa la autenticación al arrancar la app
  static Future<bool> initializeAuth() async {
    try {
      print('🚀 Inicializando autenticación...');
      
      // Cargar datos de autenticación guardados
      final authData = await AuthPersistenceService.loadAuthData();
      
      if (authData != null) {
        // Restaurar sesión en UserService
        final token = authData['token'] as String;
        final userData = authData['userData'] as Map<String, dynamic>;
        
        // Sincronizar con UserService para mantener compatibilidad
        UserService.setAuthToken(token, userData);
        
        print('✅ Sesión restaurada automáticamente');
        print('👤 Usuario: ${userData['username'] ?? userData['email']}');
        print('🔑 Token: ${token.substring(0, 20)}...');
        
        return true;
      } else {
        print('🔍 No hay sesión guardada, usuario debe hacer login');
        return false;
      }
    } catch (e) {
      print('❌ Error al inicializar autenticación: $e');
      return false;
    }
  }
  
  /// Verifica si hay una sesión válida guardada
  static Future<bool> hasValidSession() async {
    try {
      return await AuthPersistenceService.isUserLoggedIn();
    } catch (e) {
      return false;
    }
  }
  
  /// Obtiene información de la sesión actual
  static Future<Map<String, dynamic>> getSessionInfo() async {
    try {
      final sessionInfo = await AuthPersistenceService.getSessionInfo();
      final userData = await AuthPersistenceService.getCurrentUserData();
      
      return {
        ...sessionInfo,
        'userData': userData,
      };
    } catch (e) {
      return {
        'isLoggedIn': false,
        'loginTimestamp': null,
        'expiryTimestamp': null,
        'hasToken': false,
        'hasUserData': false,
        'userData': null,
      };
    }
  }
  
  /// Limpia la sesión (logout)
  static Future<void> logout({bool expired = false}) async {
    try {
      print('🚪 Cerrando sesión...');
      
      // Limpiar datos de persistencia
      await AuthPersistenceService.clearAuthData();
      
      // Limpiar UserService (solo datos en memoria, no llamar a métodos que puedan crear bucles)
      UserService.clearUserDataInMemory();
      
      // Resetear TrainingStateService para evitar errores de disposición
      try {
        TrainingStateService().reset();
        print('🔄 TrainingStateService reseteado');
      } catch (e) {
        print('⚠️ Error al resetear TrainingStateService: $e');
      }
      
      // Guardar flag de sesión expirada si aplica
      if (expired) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('session_expired', true);
      }
      
      print('✅ Sesión cerrada correctamente');
    } catch (e) {
      print('❌ Error al cerrar sesión: $e');
    }
  }
  
  /// Refresca la sesión (útil para mantener la sesión activa)
  static Future<bool> refreshSession() async {
    try {
      final authData = await AuthPersistenceService.loadAuthData();
      
      if (authData != null) {
        // Actualizar timestamp de login
        final userData = authData['userData'] as Map<String, dynamic>;
        await AuthPersistenceService.updateUserData(userData);
        
        print('🔄 Sesión refrescada');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error al refrescar sesión: $e');
      return false;
    }
  }
} 
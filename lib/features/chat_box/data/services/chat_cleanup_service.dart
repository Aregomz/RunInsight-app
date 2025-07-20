import 'package:shared_preferences/shared_preferences.dart';
import '../datasources/chat_local_datasource.dart';

class ChatCleanupService {
  static const String _lastCleanupKey = 'chat_last_cleanup_date';
  
  /// Verifica si debe limpiar el historial (cada domingo)
  static Future<bool> shouldCleanup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCleanupString = prefs.getString(_lastCleanupKey);
      
      if (lastCleanupString == null) {
        // Primera vez, guardar fecha actual
        await _saveCleanupDate();
        return false;
      }
      
      final lastCleanup = DateTime.parse(lastCleanupString);
      final now = DateTime.now();
      
      // Verificar si es domingo y han pasado al menos 7 días desde la última limpieza
      final isSunday = now.weekday == DateTime.sunday;
      final daysSinceLastCleanup = now.difference(lastCleanup).inDays;
      
      return isSunday && daysSinceLastCleanup >= 7;
    } catch (e) {
      print('❌ Error al verificar limpieza: $e');
      return false;
    }
  }
  
  /// Ejecuta la limpieza del historial
  static Future<void> performCleanup(int userId) async {
    try {
      print('🧹 Iniciando limpieza automática del historial...');
      
      final storageService = ChatStorageService(userId);
      await storageService.clearMessages();
      
      await _saveCleanupDate();
      
      print('✅ Limpieza automática completada');
    } catch (e) {
      print('❌ Error durante la limpieza automática: $e');
    }
  }
  
  /// Guarda la fecha de la última limpieza
  static Future<void> _saveCleanupDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      await prefs.setString(_lastCleanupKey, now.toIso8601String());
      print('📅 Fecha de limpieza guardada: ${now.toIso8601String()}');
    } catch (e) {
      print('❌ Error al guardar fecha de limpieza: $e');
    }
  }
  
  /// Obtiene la fecha de la próxima limpieza
  static Future<DateTime?> getNextCleanupDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCleanupString = prefs.getString(_lastCleanupKey);
      
      if (lastCleanupString == null) {
        return null;
      }
      
      final lastCleanup = DateTime.parse(lastCleanupString);
      final nextCleanup = lastCleanup.add(const Duration(days: 7));
      
      return nextCleanup;
    } catch (e) {
      print('❌ Error al obtener próxima fecha de limpieza: $e');
      return null;
    }
  }
  
  /// Verifica si la limpieza está habilitada
  static Future<bool> isCleanupEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('chat_cleanup_enabled') ?? true; // Por defecto habilitado
    } catch (e) {
      return true;
    }
  }
  
  /// Habilita o deshabilita la limpieza automática
  static Future<void> setCleanupEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('chat_cleanup_enabled', enabled);
      print('🔧 Limpieza automática ${enabled ? 'habilitada' : 'deshabilitada'}');
    } catch (e) {
      print('❌ Error al configurar limpieza automática: $e');
    }
  }
} 
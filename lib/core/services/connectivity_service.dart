import 'dart:async';
import 'dart:io';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
  bool _isConnected = true;
  Timer? _connectionCheckTimer;

  /// Stream para escuchar cambios en la conectividad
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  /// Estado actual de la conexión
  bool get isConnected => _isConnected;

  /// Inicializar el servicio de conectividad
  Future<void> initialize() async {
    try {
      print('🌐 Inicializando servicio de conectividad...');
      
      // Verificar estado inicial
      await _checkConnectionStatus();
      
      // Verificar conexión periódicamente (cada 30 segundos)
      _connectionCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        _checkConnectionStatus();
      });
      
      print('✅ Servicio de conectividad inicializado');
    } catch (e) {
      print('❌ Error al inicializar servicio de conectividad: $e');
    }
  }

  /// Verificar el estado actual de la conexión
  Future<bool> _checkConnectionStatus() async {
    try {
      // Verificar conectividad real a internet
      final hasInternet = await _checkInternetConnection();
      _updateConnectionStatus(hasInternet);
      return hasInternet;
    } catch (e) {
      print('❌ Error al verificar estado de conexión: $e');
      _updateConnectionStatus(false);
      return false;
    }
  }

  /// Verificar conexión real a internet
  Future<bool> _checkInternetConnection() async {
    try {
      // Intentar conectar a un servidor confiable
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      print('❌ Error al verificar conexión a internet: $e');
      return false;
    }
  }

  /// Actualizar estado de conexión
  void _updateConnectionStatus(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _connectionStatusController.add(isConnected);
      
      print('🌐 Estado de conexión: ${isConnected ? "Conectado" : "Desconectado"}');
      
      // Notificar cambio de estado
      if (isConnected) {
        print('✅ Conexión a internet restaurada');
      } else {
        print('⚠️ Sin conexión a internet');
      }
    }
  }

  /// Verificar conectividad de forma síncrona
  Future<bool> checkConnectivity() async {
    return await _checkConnectionStatus();
  }

  /// Obtener tipo de conexión actual (simplificado)
  Future<String> getConnectionType() async {
    try {
      final isConnected = await _checkInternetConnection();
      return isConnected ? 'Conectado' : 'Sin conexión';
    } catch (e) {
      return 'Error';
    }
  }

  /// Disparar verificación manual de conexión
  Future<void> forceCheck() async {
    print('🔍 Verificación manual de conectividad...');
    await _checkConnectionStatus();
  }

  /// Limpiar recursos
  void dispose() {
    _connectionCheckTimer?.cancel();
    _connectionStatusController.close();
    print('🧹 Servicio de conectividad limpiado');
  }
} 
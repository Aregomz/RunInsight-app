import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import 'interceptors.dart';

class DioClient {
  static Dio? _instance;
  
  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }
  
  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Agregar interceptores
    dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
    ]);
    
    return dio;
  }
  
  // Métodos helper para hacer requests
  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return instance.get(path, queryParameters: queryParameters);
  }
  
  static Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return instance.post(path, data: data, queryParameters: queryParameters);
  }
  
  static Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return instance.put(path, data: data, queryParameters: queryParameters);
  }
  
  static Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) {
    return instance.delete(path, queryParameters: queryParameters);
  }
  
  // Método para manejar errores de manera consistente
  static String handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Error de conexión: Tiempo de espera agotado';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;
          
          if (data is Map<String, dynamic>) {
            return data['message'] ?? data['error'] ?? 'Error del servidor';
          }
          
          switch (statusCode) {
            case 400:
              return 'Datos inválidos';
            case 401:
              return 'No autorizado';
            case 403:
              return 'Acceso denegado';
            case 404:
              return 'Recurso no encontrado';
            case 409:
              return 'Conflicto: El recurso ya existe';
            case 422:
              return 'Datos de validación incorrectos';
            case 500:
              return 'Error interno del servidor';
            case 502:
              return 'Error de conexión con el servidor';
            case 503:
              return 'Servicio no disponible temporalmente';
            default:
              return 'Error del servidor: $statusCode';
          }
        case DioExceptionType.cancel:
          return 'Solicitud cancelada';
        case DioExceptionType.connectionError:
          return 'Error de conexión: No se pudo conectar al servidor';
        case DioExceptionType.badCertificate:
          return 'Error de certificado SSL';
        case DioExceptionType.unknown:
        default:
          return 'Error desconocido: ${error.message}';
      }
    }
    
    return 'Error inesperado: $error';
  }
}

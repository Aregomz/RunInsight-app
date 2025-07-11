import 'package:dio/dio.dart';
import '../../../features/user/data/services/user_service.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Agregar token de autenticación si existe
    final token = UserService.getAuthToken();
    if (token != null && token.isNotEmpty) {
      // Agregar token en múltiples formatos para compatibilidad
      options.headers['Authorization'] = 'Bearer $token';
      options.headers['X-Auth-Token'] = token;
      options.headers['token'] = token;
      
      print('🔑 Token agregado: $token');
    } else {
      print('⚠️ No hay token disponible');
    }
    
    // Agregar headers por defecto
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    
    print('🌐 [REQUEST] ${options.method} ${options.path}');
    print('🌐 [HEADERS] ${options.headers}');
    if (options.data != null) {
      print('🌐 [BODY] ${options.data}');
    }
    
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ [RESPONSE] ${response.statusCode} ${response.requestOptions.path}');
    print('✅ [BODY] ${response.data}');
    
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ [ERROR] ${err.response?.statusCode} ${err.requestOptions.path}');
    print('❌ [MESSAGE] ${err.message}');
    print('❌ [RESPONSE] ${err.response?.data}');
    
    handler.next(err);
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('📡 [API REQUEST] ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('📡 [API RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('📡 [API ERROR] ${err.response?.statusCode} ${err.requestOptions.uri}');
    handler.next(err);
  }
}

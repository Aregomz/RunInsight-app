// features/auth/presentation/cubit/auth_bloc.dart
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import '../../../user/data/services/user_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const String _baseUrl =
      'https://api-gateway-runinsight-production.up.railway.app';

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        // Preparar los datos del login
        final loginData = {'email': event.email, 'password': event.password};

        print('🔐 Enviando datos de login: ${json.encode(loginData)}');

        // Hacer la petición POST a Railway
        final response = await http.post(
          Uri.parse('$_baseUrl/users/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(loginData),
        );

        print('🔐 Código de respuesta login: ${response.statusCode}');
        print('🔐 Cuerpo de respuesta login: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Login exitoso - extraer token y datos del usuario
          final responseData = json.decode(response.body);
          final userData = responseData['user'] ?? responseData;
          final token =
              userData['token'] ??
              responseData['token'] ??
              responseData['access_token'];

          print('🔍 Token encontrado: $token');
          print('🔍 Datos del usuario: $userData');

          if (token != null) {
            // Guardar solo el token y ID para que UserService obtenga datos reales de la API
            final userInfo = {
              'id': userData['id'],
              'token': token,
              'rolesId': userData['rolesId'],
            };

            UserService.setAuthToken(token, userInfo);
            print('✅ Token y ID guardados para obtener datos reales de la API');
            print('✅ Datos mínimos guardados: $userInfo');
            print('🔑 Token guardado en UserService: $token');
          } else {
            print('❌ No se encontró token en la respuesta');
          }

          print('✅ Login exitoso');
          emit(AuthSuccess());
        } else {
          // Error en el login
          String errorMessage = 'Credenciales incorrectas';

          try {
            final errorData = json.decode(response.body);
            errorMessage =
                errorData['message'] ?? errorData['error'] ?? errorMessage;
          } catch (jsonError) {
            if (response.body.isNotEmpty) {
              errorMessage = response.body;
            } else {
              errorMessage =
                  'Error ${response.statusCode}: ${response.reasonPhrase}';
            }
          }

          print('❌ Error en login: $errorMessage');
          emit(AuthFailure(errorMessage));
        }
      } catch (e) {
        // Error de conexión
        print('❌ Error de conexión en login: $e');
        emit(AuthFailure('Error de conexión: $e'));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        // Verificar conectividad con el servidor primero
        print('🔍 Verificando conectividad con el servidor...');
        try {
          // Probar el endpoint de registro con un GET para ver si responde
          final healthCheck = await http
              .get(
                Uri.parse('$_baseUrl/users'),
                headers: {'Content-Type': 'application/json'},
              )
              .timeout(const Duration(seconds: 5));
          print('🔍 Endpoint /users responde con: ${healthCheck.statusCode}');
        } catch (e) {
          print('⚠️ Endpoint /users no responde a GET: $e');
        }

        // Preparar los datos del usuario
        final baseData = {
          'name': event.name,
          'email': event.email,
          'genderId': int.tryParse(event.gender),
          'username': event.username,
          'password': event.password,
          'birthdate': _formatBirthDate(event.age),
          'weight': event.weight,
          'height': event.height,
        };

        print('🌐 Datos base: ${json.encode(baseData)}');
        print('🔍 Datos individuales:');
        print('  - name: ${event.name}');
        print('  - email: ${event.email}');
        print('  - gender: ${event.gender}');
        print('  - username: ${event.username}');
        print('  - password: ${event.password.length} caracteres');
        print('  - birthdate: ${_formatBirthDate(event.age)}');
        print('  - weight: ${event.weight}');
        print('  - height: ${event.height}');
        print('🌐 URL de la API: $_baseUrl/users');

        // Intentar registro con diferentes formatos
        try {
          final response = await _tryRegisterWithDifferentFormats(baseData);

          print('🌐 Código de respuesta: ${response.statusCode}');
          print('🌐 Cuerpo de respuesta: ${response.body}');

          if (response.statusCode == 201 || response.statusCode == 200) {
            // Usuario creado exitosamente
            print('✅ Usuario creado exitosamente');
            emit(AuthSuccess());
          } else {
            // Error en la creación
            String errorMessage = 'Error al crear usuario';

            try {
              final errorData = json.decode(response.body);
              errorMessage =
                  errorData['message'] ?? errorData['error'] ?? errorMessage;

              // Manejo específico para diferentes códigos de error
              if (response.statusCode == 500) {
                errorMessage =
                    'Error del servidor. El servidor está experimentando problemas técnicos. Por favor, intenta más tarde o contacta al soporte técnico.';
              } else if (response.statusCode == 400) {
                errorMessage =
                    'Datos inválidos. Verifica la información ingresada.';
              } else if (response.statusCode == 409) {
                errorMessage = 'El email o username ya está registrado.';
              } else if (response.statusCode == 422) {
                errorMessage = 'Datos de validación incorrectos.';
              } else if (response.statusCode == 503) {
                errorMessage = 'Servicio no disponible temporalmente.';
              } else if (response.statusCode == 502) {
                errorMessage = 'Error de conexión con el servidor.';
              } else if (response.statusCode == 404) {
                errorMessage = 'Endpoint no encontrado.';
              } else if (response.statusCode == 403) {
                errorMessage = 'Acceso denegado.';
              }
            } catch (jsonError) {
              // Si no es JSON válido, usar el cuerpo de la respuesta como mensaje
              if (response.body.isNotEmpty) {
                errorMessage = response.body;
              } else {
                errorMessage =
                    'Error ${response.statusCode}: ${response.reasonPhrase}';
              }
            }

            print('❌ Error al crear usuario: $errorMessage');
            print('❌ Código de estado: ${response.statusCode}');
            print('❌ Respuesta del servidor: ${response.body}');
            print('❌ Headers de respuesta: ${response.headers}');
            emit(AuthFailure(errorMessage));
          }
        } catch (e) {
          print('❌ Error en registro con múltiples formatos: $e');
          emit(AuthFailure('Error al crear usuario: $e'));
        }
      } catch (e) {
        // Error de conexión
        print('❌ Error de conexión: $e');
        emit(AuthFailure('Error de conexión: $e'));
      }
    });
  }

  String _formatBirthDate(String age) {
    // Convertir edad a fecha de nacimiento
    int ageInt = int.tryParse(age) ?? 25;
    DateTime now = DateTime.now();
    DateTime birthDate = now.subtract(Duration(days: ageInt * 365));
    return '${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';
  }

  Future<http.Response> _tryRegisterWithDifferentFormats(
    Map<String, dynamic> baseData,
  ) async {
    // Formato mínimo: solo email y password
    final minimalFormat = {
      'email': baseData['email'],
      'password': baseData['password'],
    };

    print('🔄 Probando formato mínimo: ${json.encode(minimalFormat)}');
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/users'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(minimalFormat),
          )
          .timeout(const Duration(seconds: 10));

      print('📊 Respuesta del servidor:');
      print('  - Status Code: ${response.statusCode}');
      print('  - Body: ${response.body}');
      print('  - Headers: ${response.headers}');

      return response;
    } catch (e) {
      print('❌ Error en formato mínimo: $e');

      // Si falla, probar con formato simple
      final simpleFormat = {
        'name': baseData['name'],
        'email': baseData['email'],
        'username': baseData['username'],
        'password': baseData['password'],
      };

      print('🔄 Probando formato simple: ${json.encode(simpleFormat)}');
      try {
        final response = await http
            .post(
              Uri.parse('$_baseUrl/users'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(simpleFormat),
            )
            .timeout(const Duration(seconds: 10));

        print('📊 Respuesta del servidor:');
        print('  - Status Code: ${response.statusCode}');
        print('  - Body: ${response.body}');
        print('  - Headers: ${response.headers}');

        return response;
      } catch (e2) {
        print('❌ Error en formato simple: $e2');
        rethrow;
      }
    }
  }
}

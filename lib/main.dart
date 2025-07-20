// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/navigation/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/data/services/auth_init_service.dart';
import 'core/di/dependency_injection.dart';
import 'core/services/connectivity_service.dart';
import 'features/user/data/services/user_service.dart';
import 'features/user/presentation/bloc/user_bloc.dart';

void main() async {
  // Optimizaciones para mejorar el rendimiento
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar UserService para cargar el token desde SharedPreferences
  await UserService.init();
  
  // Inicializar autenticación y restaurar sesión si existe
  final hasSession = await AuthInitService.initializeAuth();
  print('🔐 Estado de autenticación: ${hasSession ? "Sesión restaurada" : "Sin sesión"}');
  
  // Inicializar servicio de conectividad
  await ConnectivityService().initialize();
  print('🌐 Servicio de conectividad inicializado');
  
  // Configurar el modo de debug para mejor rendimiento
  if (kDebugMode) {
    debugPrintRebuildDirtyWidgets = false;
  }
  
  runApp(const RunInsightApp());
}

class RunInsightApp extends StatelessWidget {
  const RunInsightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => DependencyInjection.getAuthBloc(),
        ),
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        // Optimizaciones de rendimiento
        showPerformanceOverlay: false,
        showSemanticsDebugger: false,
        theme: ThemeData.dark().copyWith(
          textTheme: ThemeData.dark().textTheme.apply(
                fontFamily: 'Montserrat',
              ),
        ),
      ),
    );
  }
}
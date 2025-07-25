// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/navigation/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  // Optimizaciones para mejorar el rendimiento
  WidgetsFlutterBinding.ensureInitialized();
  
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
    return BlocProvider(
      create: (context) => AuthBloc(),
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
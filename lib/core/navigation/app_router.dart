import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runinsight/commons/widgets/app_shell.dart';
import 'package:runinsight/features/auth/presentation/pages/register_page.dart';
import 'package:runinsight/features/auth/presentation/pages/welcome_page.dart';
import 'package:runinsight/features/home/presentation/pages/home_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const WelcomePage(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterPage(),
      ),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomePage(),
          ),
          // futuras rutas: /coach, /profile, /social, etc.
        ],
      ),
    ],
  );
}

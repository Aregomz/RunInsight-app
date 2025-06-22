// core/navigation/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:runinsight/features/auth/presentation/pages/register_page.dart';
import 'package:runinsight/features/auth/presentation/pages/welcome_page.dart';

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
    ],
  );
}

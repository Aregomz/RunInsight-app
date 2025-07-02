import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runinsight/commons/widgets/app_shell.dart';
import 'package:runinsight/features/auth/presentation/pages/register_page.dart';
import 'package:runinsight/features/auth/presentation/pages/welcome_page.dart';
import 'package:runinsight/features/home/presentation/pages/home_page.dart';
import 'package:runinsight/features/profile/presentation/pages/profile_page.dart';
import 'package:runinsight/features/ranking/presentation/pages/ranking_page.dart';
import 'package:runinsight/features/trainings/presentation/pages/trainings_page.dart';
import 'package:runinsight/features/active_training/presentation/pages/TrainingInProgressPage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runinsight/features/active_training/presentation/bloc/active_training_bloc.dart';
import 'package:runinsight/features/active_training/domain/usecases/start_training.dart';
import 'package:runinsight/features/active_training/domain/usecases/update_training_metrics.dart';
import 'package:runinsight/features/active_training/domain/usecases/finish_training.dart';
import 'package:runinsight/features/active_training/domain/usecases/get_training_summary.dart';
import 'package:runinsight/features/active_training/domain/repositories/active_training_repository.dart';
import 'package:runinsight/features/active_training/domain/entities/active_training_session.dart';

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
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfilePage(),
          ),
           GoRoute(
            path: '/ranking',
            builder: (_, __) => const RankingPage(),
          ),
           GoRoute(
            path: '/trainings',
            builder: (_, __) => const TrainingsPage(),
          ),
          GoRoute(
            path: '/training_in_progress',
            builder: (_, __) => BlocProvider(
              create: (_) => ActiveTrainingBloc(
                startTraining: StartTraining(_DummyActiveTrainingRepository()),
                updateTrainingMetrics: UpdateTrainingMetrics(_DummyActiveTrainingRepository()),
                finishTraining: FinishTraining(_DummyActiveTrainingRepository()),
                getTrainingSummary: GetTrainingSummary(_DummyActiveTrainingRepository()),
              ),
              child: const TrainingInProgressPage(),
            ),
          ),
          // futuras rutas: /coach, /social, etc.
        ],
      ),
    ],
  );
}

// Dummy repository para pruebas locales
class _DummyActiveTrainingRepository implements ActiveTrainingRepository {
  @override
  Future<void> finishTraining() async {}

  @override
  Future<ActiveTrainingSession?> getActiveTraining() async => null;

  @override
  Future<ActiveTrainingSession> getSummary() async => ActiveTrainingSession.empty();

  @override
  Future<void> startTraining() async {}

  @override
  Future<void> updateMetrics(ActiveTrainingSession session) async {}

  @override
  Future<ActiveTrainingSession> endTraining() async => ActiveTrainingSession.empty();
}

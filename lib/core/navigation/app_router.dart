import 'package:go_router/go_router.dart';
import 'package:runinsight/commons/widgets/app_shell.dart';
import 'package:runinsight/features/auth/presentation/pages/register_page.dart';
import 'package:runinsight/features/auth/presentation/pages/welcome_page.dart';
import 'package:runinsight/features/home/presentation/pages/home_page.dart';
import 'package:runinsight/features/profile/presentation/pages/profile_page.dart';
import 'package:runinsight/features/ranking/presentation/pages/ranking_page.dart';
import 'package:runinsight/features/trainings/presentation/pages/trainings_page.dart';
import 'package:runinsight/features/active_training/presentation/pages/TrainingInProgressPage.dart';
import 'package:runinsight/features/active_training/presentation/pages/training_summary_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runinsight/features/active_training/presentation/bloc/active_training_bloc.dart';
import 'package:runinsight/features/active_training/domain/repositories/active_training_repository.dart';
import 'package:runinsight/features/active_training/domain/entities/active_training_session.dart';
import 'package:runinsight/features/active_training/domain/usecases/save_active_training.dart';
import 'package:runinsight/features/active_training/data/repositories/active_training_repository_impl.dart';
import 'package:runinsight/features/active_training/data/datasources/active_training_remote_datasource.dart';
import 'package:runinsight/features/active_training/data/services/training_data_service.dart';
import 'package:runinsight/features/chat_box/presentation/pages/chat_screen.dart';
import 'package:runinsight/features/trainings/presentation/bloc/trainings_bloc.dart';
import 'package:runinsight/features/trainings/domain/usecases/get_user_trainings.dart';
import 'package:runinsight/features/trainings/data/repositories/trainings_repository_impl.dart';
import 'package:runinsight/features/trainings/data/datasources/trainings_remote_datasource.dart';
import 'package:runinsight/core/network/dio_client.dart';
import 'package:runinsight/features/home/presentation/bloc/home_bloc.dart';
import 'package:runinsight/features/home/domain/usecases/get_weekly_stats.dart';
import 'package:runinsight/features/home/data/repositories/weekly_stats_repository_impl.dart';
import 'package:runinsight/features/home/data/datasources/weekly_stats_remote_datasource.dart';
import 'package:runinsight/features/home/domain/usecases/get_weather.dart';
import 'package:runinsight/features/home/data/repositories/weather_repository_impl.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const WelcomePage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => BlocProvider(
              create: (_) => HomeBloc(
                getWeeklyStats: GetWeeklyStats(
                  WeeklyStatsRepositoryImpl(
                    remoteDataSource: WeeklyStatsRemoteDataSourceImpl(
                      dio: DioClient.instance,
                    ),
                  ),
                ),
                getWeather: GetWeather(
                  WeatherRepositoryImpl(),
                ),
              ),
              child: const HomePage(),
            ),
          ),
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
          GoRoute(path: '/ranking', builder: (_, __) => const RankingPage()),
          GoRoute(
            path: '/trainings',
            builder: (_, __) => BlocProvider(
              create: (_) => TrainingsBloc(
                getUserTrainings: GetUserTrainings(
                  TrainingsRepositoryImpl(
                    remoteDataSource: TrainingsRemoteDataSourceImpl(
                      dio: DioClient.instance,
                    ),
                  ),
                ),
              ),
              child: const TrainingsPage(),
            ),
          ),
          GoRoute(
            path: '/training_in_progress',
            builder: (_, __) => BlocProvider(
              create: (_) => ActiveTrainingBloc(
                saveActiveTraining: SaveActiveTraining(
                  ActiveTrainingRepositoryImpl(
                    remoteDatasource: ActiveTrainingRemoteDatasourceImpl(),
                  ),
                ),
              ),
              child: const TrainingInProgressPage(),
            ),
          ),
          GoRoute(
            path: '/training-summary',
            builder: (context, state) {
              // Obtener los datos del entrenamiento desde el servicio
              final trainingData = TrainingDataService.getLastTrainingData();
              
              if (trainingData == null) {
                // Si no hay datos, mostrar datos de ejemplo y mensaje
                return TrainingSummaryPage(trainingData: {
                  'time_minutes': '0',
                  'distance_km': '0.0',
                  'rhythm': '0.0',
                  'altitude': '0',
                  'trainingType': 'Carrera',
                  'terrainType': 'Pavimento',
                  'weather': 'No disponible',
                  'notes': '',
                  'date': '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
                });
              }
              
              return TrainingSummaryPage(trainingData: trainingData);
            },
          ),
          GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
          // futuras rutas: /coach, /social, etc.
        ],
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runinsight/commons/widgets/app_shell.dart';
import 'package:runinsight/features/auth/presentation/pages/register_page.dart';
import 'package:runinsight/features/auth/presentation/pages/welcome_page.dart';
import 'package:runinsight/features/home/presentation/pages/home_page.dart';
import 'package:runinsight/features/profile/presentation/pages/profile_page.dart';
import 'package:runinsight/features/profile/presentation/pages/profile_edit_page.dart';
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
import 'package:runinsight/features/ranking/domain/usecases/add_friend.dart';
import 'package:runinsight/features/ranking/data/repositories/friends_ranking_repository_impl.dart';
import 'package:runinsight/features/ranking/data/datasources/friends_ranking_remote_datasource.dart';
import 'package:runinsight/features/ranking/data/datasources/badges_remote_datasource.dart';
import 'package:runinsight/features/user/data/services/user_service.dart';
import 'package:runinsight/features/active_training/data/services/training_state_service.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    // Configurar para manejar URLs externas (deep links)
    redirect: (context, state) {
      // Manejar deep links con scheme personalizado
      final location = state.uri.toString();
      if (location.startsWith('runinsight://')) {
        // Extraer el friendId del deep link
        final path = location.replaceFirst('runinsight://', '');
        if (path.startsWith('invite/')) {
          final friendId = path.replaceFirst('invite/', '');
          // Procesar la invitación
          _processInvitationFromDeepLink(context, int.tryParse(friendId) ?? 0);
          // Redirigir al home
          return '/home';
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const WelcomePage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      // Ruta para manejar invitaciones de amigos
      GoRoute(
        path: '/invite/:friendId',
        builder: (context, state) {
          final friendId = int.tryParse(state.pathParameters['friendId'] ?? '');
          if (friendId != null) {
            // Procesar la invitación automáticamente
            _processInvitation(context, friendId);
          }
          // Redirigir al home después de procesar
          return const WelcomePage();
        },
      ),
      ShellRoute(
        builder: (_, __, child) => ChangeNotifierProvider(
          create: (_) => TrainingStateService(),
          child: AppShell(),
        ),
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
          GoRoute(
            path: '/edit-profile',
            name: 'profile-edit',
            builder: (context, state) {
              print('Debug: Building /profile/edit route');
              final extra = state.extra as Map<String, dynamic>?;
              print('Debug: extra = $extra');
              
              final userId = extra?['userId'] as String? ?? '';
              final currentUserData = extra?['currentUserData'] as Map<String, dynamic>? ?? {};
              
              print('Debug: userId from route = $userId');
              print('Debug: currentUserData from route = $currentUserData');
              
              if (userId.isEmpty) {
                return Scaffold(
                  backgroundColor: const Color(0xFF1A1A1A),
                  appBar: AppBar(
                    backgroundColor: const Color(0xFF1A1A1A),
                    foregroundColor: Colors.white,
                    title: const Text('Error', style: TextStyle(color: Colors.white)),
                  ),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Error: ID de usuario no válido',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.pop(),
                          child: const Text('Volver'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return ProfileEditPage(
                userId: userId,
                currentUserData: currentUserData,
              );
            },
          ),
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

  // Método para procesar invitaciones desde deep links
  static void _processInvitationFromDeepLink(BuildContext context, int friendId) async {
    try {
      final currentUserId = UserService.getUserId();
      if (currentUserId == null) {
        // Si no hay usuario autenticado, mostrar mensaje
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debes iniciar sesión para agregar amigos'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Evitar agregarse a sí mismo como amigo
      if (currentUserId == friendId) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No puedes agregarte a ti mismo como amigo'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final addFriendUseCase = AddFriendUseCase(
        FriendsRankingRepositoryImpl(
          remoteDataSource: FriendsRankingRemoteDataSourceImpl(
            dio: DioClient.instance,
          ),
          badgesRemoteDataSource: BadgesRemoteDataSourceImpl(),
        ),
      );

      await addFriendUseCase(currentUserId, friendId);
      
      // Mostrar mensaje de éxito
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Amigo agregado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Mostrar mensaje de error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar amigo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Método para procesar invitaciones automáticamente
  static void _processInvitation(BuildContext context, int friendId) async {
    try {
      final currentUserId = UserService.getUserId();
      if (currentUserId == null) {
        // Si no hay usuario autenticado, no se puede agregar amigo
        return;
      }

      // Evitar agregarse a sí mismo como amigo
      if (currentUserId == friendId) {
        return;
      }

      final addFriendUseCase = AddFriendUseCase(
        FriendsRankingRepositoryImpl(
          remoteDataSource: FriendsRankingRemoteDataSourceImpl(
            dio: DioClient.instance,
          ),
          badgesRemoteDataSource: BadgesRemoteDataSourceImpl(),
        ),
      );

      await addFriendUseCase(currentUserId, friendId);
      
      // Mostrar mensaje de éxito
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Amigo agregado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Mostrar mensaje de error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar amigo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

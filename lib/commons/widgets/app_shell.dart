import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/active_training/data/services/training_state_service.dart';
import '../../features/ranking/presentation/pages/ranking_page.dart';
import '../../features/chat_box/presentation/pages/chat_screen.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/trainings/presentation/pages/trainings_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/domain/usecases/get_weekly_stats.dart';
import '../../features/home/data/repositories/weekly_stats_repository_impl.dart';
import '../../features/home/data/datasources/weekly_stats_remote_datasource.dart';
import '../../features/home/domain/usecases/get_weather.dart';
import '../../features/home/data/repositories/weather_repository_impl.dart';
import '../../features/ranking/presentation/bloc/ranking_bloc.dart';
import '../../features/ranking/domain/usecases/get_ranking.dart';
import '../../features/ranking/domain/usecases/get_user_position.dart';
import '../../features/ranking/domain/usecases/get_user_badges.dart';
import '../../features/ranking/data/repositories/friends_ranking_repository_impl.dart';
import '../../features/ranking/data/datasources/friends_ranking_remote_datasource.dart';
import '../../features/ranking/data/datasources/badges_remote_datasource.dart';
import '../../features/trainings/presentation/bloc/trainings_bloc.dart';
import '../../features/trainings/domain/usecases/get_user_trainings.dart';
import '../../features/trainings/data/repositories/trainings_repository_impl.dart';
import '../../features/trainings/data/datasources/trainings_remote_datasource.dart';
import '../../core/network/dio_client.dart';
import '../../features/chat_box/presentation/bloc/chat_box_bloc.dart';
import '../../features/chat_box/domain/usecases/send_message.dart';
import '../../features/chat_box/data/repositories/chat_repository_impl.dart';
import '../../core/services/gemini_api_service.dart';
import 'package:runinsight/features/user/data/services/user_service.dart';
import '../../features/events/presentation/bloc/events_bloc.dart';
import '../../features/events/domain/usecases/get_future_events.dart';
import '../../features/events/data/repositories/events_repository_impl.dart';
import '../../features/events/data/datasources/events_remote_datasource.dart';
import '../../features/events/presentation/widgets/events_handler.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({required this.child, super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final PageController _pageController = PageController(initialPage: 2);
  int _currentIndex = 2;

  // Ahora la lista de páginas solo contiene los widgets, sin providers
  final List<Widget> _pages = const [
    RankingPage(),
    ChatScreen(),
    HomePage(),
    TrainingsPage(),
    ProfilePage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isTrainingActive = false;
    bool providerAvailable = true;
    try {
      final trainingState = Provider.of<TrainingStateService>(
        context,
        listen: true,
      );
      isTrainingActive = trainingState.isTrainingActive;
    } catch (e) {
      providerAvailable = false;
    }

    // Obtener la ruta actual de forma compatible con go_router
    final location = GoRouterState.of(context).uri.path;
    const mainRoutes = ['/home', '/ranking', '/chat', '/trainings', '/profile'];
    final isMainRoute = mainRoutes.contains(location);
    final isTrainingRoute = location == '/training_in_progress';

    // DEBUG: Imprimir la ruta actual y si es principal
    print('AppShell: GoRouter location = $location');
    print('AppShell: isMainRoute = $isMainRoute');
    print('AppShell: isTrainingRoute = $isTrainingRoute');
    print('AppShell: isTrainingActive = $isTrainingActive');

    final showNavBar = (isMainRoute || (isTrainingRoute && !isTrainingActive)) && (providerAvailable || !isTrainingActive);

    // Instancias de repositorios y usecases para los blocs
    final badgesDataSource = BadgesRemoteDataSourceImpl();
    final rankingRepository = FriendsRankingRepositoryImpl(
      remoteDataSource: FriendsRankingRemoteDataSourceImpl(dio: DioClient.instance),
      badgesRemoteDataSource: badgesDataSource,
    );
    final trainingsRepository = TrainingsRepositoryImpl(
      remoteDataSource: TrainingsRemoteDataSourceImpl(dio: DioClient.instance),
    );
    final homeStatsRepository = WeeklyStatsRepositoryImpl(
      remoteDataSource: WeeklyStatsRemoteDataSourceImpl(dio: DioClient.instance),
    );
    final weatherRepository = WeatherRepositoryImpl();
    final userId = UserService.getUserId();
    if (userId == null) {
      return const Center(child: Text('Error: Usuario no autenticado'));
    }
    final chatRepository = ChatRepositoryImpl(
      geminiApiService: GeminiApiService(),
      userId: userId,
    );

    // Instancias para Events
    final eventsDataSource = EventsRemoteDataSourceImpl();
    final eventsRepository = EventsRepositoryImpl(
      remoteDataSource: eventsDataSource,
    );

    return flutter_bloc.MultiBlocProvider(
      providers: [
        flutter_bloc.BlocProvider<RankingBloc>(
          create: (_) => RankingBloc(
            getRankingUseCase: GetRankingUseCase(rankingRepository),
            getUserPosition: GetUserPosition(rankingRepository),
            getUserBadges: GetUserBadges(repository: rankingRepository),
          ),
        ),
        flutter_bloc.BlocProvider<ChatBloc>(
          create: (_) => ChatBloc(
            sendMessage: SendMessageUseCase(chatRepository),
            repository: chatRepository,
            userId: userId,
          ),
        ),
        flutter_bloc.BlocProvider<HomeBloc>(
          create: (_) => HomeBloc(
            getWeeklyStats: GetWeeklyStats(homeStatsRepository),
            getWeather: GetWeather(weatherRepository),
          ),
        ),
        flutter_bloc.BlocProvider<TrainingsBloc>(
          create: (_) => TrainingsBloc(
            getUserTrainings: GetUserTrainings(trainingsRepository),
          ),
        ),
        flutter_bloc.BlocProvider<EventsBloc>(
          create: (_) => EventsBloc(
            getFutureEvents: GetFutureEvents(eventsRepository),
          ),
        ),
        // Si ProfilePage necesita un bloc, agregar aquí
      ],
      child: EventsHandler(
        child: Scaffold(
          body: isMainRoute
              ? PageView(
                  controller: _pageController,
                  children: _pages,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                )
              : widget.child,
        bottomNavigationBar: showNavBar
            ? BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  // Rutas principales en el mismo orden que _pages
                  const mainRoutes = ['/ranking', '/chat', '/home', '/trainings', '/profile'];
                  if (!isMainRoute) {
                    // Si no estamos en una ruta principal, navegar con GoRouter
                    GoRouter.of(context).go(mainRoutes[index]);
                  } else {
                    // Si ya estamos en una ruta principal, solo cambiar el índice y el PageView
                    setState(() {
                      _currentIndex = index;
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    });
                  }
                },
                selectedItemColor: Colors.orangeAccent,
                unselectedItemColor: Colors.white70,
                backgroundColor: const Color(0xFF0C0C27),
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.emoji_events),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.psychology_alt),
                    label: '',
                  ),
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bar_chart),
                    label: '',
                  ),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
                ],
              )
            : null,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/active_training/data/services/training_state_service.dart';
import '../../features/ranking/presentation/pages/ranking_page.dart';
import '../../features/chat_box/presentation/pages/chat_screen.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/trainings/presentation/pages/trainings_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class AppShell extends StatefulWidget {
  const AppShell({super.key});

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
    final chatRepository = ChatRepositoryImpl(geminiApiService: GeminiApiService());

    return MultiBlocProvider(
      providers: [
        BlocProvider<RankingBloc>(
          create: (_) => RankingBloc(
            getRankingUseCase: GetRankingUseCase(rankingRepository),
            getUserPosition: GetUserPosition(rankingRepository),
            getUserBadges: GetUserBadges(repository: rankingRepository),
          ),
        ),
        BlocProvider<ChatBloc>(
          create: (_) => ChatBloc(
            sendMessage: SendMessageUseCase(chatRepository),
            repository: chatRepository,
          ),
        ),
        BlocProvider<HomeBloc>(
          create: (_) => HomeBloc(
            getWeeklyStats: GetWeeklyStats(homeStatsRepository),
            getWeather: GetWeather(weatherRepository),
          ),
        ),
        BlocProvider<TrainingsBloc>(
          create: (_) => TrainingsBloc(
            getUserTrainings: GetUserTrainings(trainingsRepository),
          ),
        ),
        // Si ProfilePage necesita un bloc, agregar aquí
      ],
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _pages,
        ),
        bottomNavigationBar:
            (!isTrainingActive && providerAvailable || !providerAvailable)
                ? BottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      setState(() {
                        _currentIndex = index;
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      });
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
    );
  }
}

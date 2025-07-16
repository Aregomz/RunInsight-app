// features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runinsight/features/user/data/services/user_service.dart';
import 'package:runinsight/features/home/presentation/widgets/greeting_header.dart';
import 'package:runinsight/features/home/presentation/widgets/calendar_widget.dart';
import 'package:runinsight/features/home/presentation/widgets/badge_summary.dart';
import 'package:runinsight/features/home/presentation/widgets/ia_coach_button.dart';
import 'package:runinsight/features/home/presentation/widgets/stats_summary.dart';
import 'package:runinsight/features/home/presentation/widgets/training_button.dart';
import 'package:runinsight/features/home/presentation/widgets/weather_info.dart';
import '../bloc/home_bloc.dart';
import 'package:runinsight/features/trainings/presentation/bloc/trainings_bloc.dart';
import 'package:runinsight/features/user/presentation/bloc/user_bloc.dart';
import 'package:runinsight/features/trainings/presentation/bloc/trainings_event.dart';
import 'package:runinsight/features/trainings/presentation/bloc/trainings_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Elimina el initState y _loadHomeData

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050510), Color(0xFF0A0A20), Color(0xFF0C0C27)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BlocListener<UserBloc, UserState>(
          listener: (context, userState) {
            if (userState is UserLoaded) {
              final userId = userState.userData['id'];
              if (userId != null) {
                print('HomePage: Disparando LoadUserTrainings para userId = $userId');
                context.read<TrainingsBloc>().add(LoadUserTrainings(userId));
              }
            }
          },
          child: BlocConsumer<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is HomeError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              // Solo dispara la carga si el estado es HomeInitial
              if (state is HomeInitial) {
                final userId = UserService.getUserId();
                if (userId != null) {
                  context.read<HomeBloc>().add(LoadHomeData(userId));
                }
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CalendarWidget(),
                    const SizedBox(height: 0),
                    GreetingHeader(),
                    const SizedBox(height: 2),
                    _buildBadgeSummary(state),
                    const SizedBox(height: 6),
                    WeatherInfoWidget(),
                    const SizedBox(height: 24),
                    TrainingButton(),
                    const SizedBox(height: 16),
                    // Print para depuración
                    (() { print('HomePage: Construyendo IACoachButton'); return SizedBox.shrink(); })(),
                    BlocBuilder<TrainingsBloc, TrainingsState>(
                      builder: (context, trainingsState) {
                        final lastTrainings = (trainingsState is TrainingsLoaded)
                            ? trainingsState.trainings.map((e) => {
                                'id': e.id,
                                'time_minutes': e.timeMinutes,
                                'distance_km': e.distanceKm,
                                'rhythm': e.rhythm,
                                'date': e.date.toIso8601String(),
                                'altitude': e.altitude,
                                'notes': e.notes,
                                'trainingType': e.trainingType,
                                'terrainType': e.terrainType,
                                'weather': e.weather,
                              }).toList()
                            : <Map<String, dynamic>>[];
                        return (state is HomeLoaded)
                            ? IACoachButton(
                                userStats: state.userData ?? {},
                                lastTrainings: lastTrainings,
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 32),
                    _buildStatsSummary(state),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSummary(HomeState state) {
    if (state is HomeLoaded && state.weeklyStats != null) {
      return StatsSummary(
        weeklyKm: double.parse(state.weeklyStats!.totalKm.toStringAsFixed(2)),
        avgPace: state.weeklyStats!.avgRhythm.toStringAsFixed(2),
      );
    } else if (state is HomeLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.orange,
        ),
      );
    } else {
      // Datos por defecto si no hay datos o hay error
      return StatsSummary(
        weeklyKm: 0.0,
        avgPace: '0.0 min/km',
      );
    }
  }

  Widget _buildBadgeSummary(HomeState state) {
    if (state is HomeLoaded) {
      return BadgeSummary(totalInsignias: state.totalBadges);
    } else if (state is HomeLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.orange,
        ),
      );
    } else {
      // Datos por defecto si no hay datos o hay error
      return const BadgeSummary(totalInsignias: 0);
    }
  }
}

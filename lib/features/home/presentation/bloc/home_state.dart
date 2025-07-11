part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();  

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final WeeklyStatsEntity? weeklyStats;
  final WeatherEntity? weather;
  final Map<String, dynamic>? userData;
  final int totalBadges;

  const HomeLoaded({
    this.weeklyStats,
    this.weather,
    this.userData,
    this.totalBadges = 0,
  });

  HomeLoaded copyWith({
    WeeklyStatsEntity? weeklyStats,
    WeatherEntity? weather,
    Map<String, dynamic>? userData,
    int? totalBadges,
  }) {
    return HomeLoaded(
      weeklyStats: weeklyStats ?? this.weeklyStats,
      weather: weather ?? this.weather,
      userData: userData ?? this.userData,
      totalBadges: totalBadges ?? this.totalBadges,
    );
  }

  @override
  List<Object?> get props => [weeklyStats, weather, userData, totalBadges];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object> get props => [message];
}

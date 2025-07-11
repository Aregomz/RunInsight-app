part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadHomeData extends HomeEvent {
  final int userId;

  const LoadHomeData(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadWeather extends HomeEvent {
  final double latitude;
  final double longitude;

  const LoadWeather(this.latitude, this.longitude);

  @override
  List<Object> get props => [latitude, longitude];
}

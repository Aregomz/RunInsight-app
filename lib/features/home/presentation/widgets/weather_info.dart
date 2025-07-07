// features/home/presentation/widgets/weather_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/weather_bloc.dart';
import '../../domain/entities/weather_entity.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/usecases/get_weather.dart';

class WeatherCard extends StatelessWidget {
  final String condition;
  final int temperature;
  final String city;

  const WeatherCard({
    super.key,
    required this.condition,
    required this.temperature,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                condition,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                city,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
          Text(
            '$temperature°C',
            style: const TextStyle(
              color: Color(0xFFFF6A00),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherInfoWidget extends StatelessWidget {
  const WeatherInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              WeatherBloc(getWeather: GetWeather(WeatherRepositoryImpl()))
                ..add(LoadWeather()),
      child: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoading) {
            return _buildLoadingWidget();
          } else if (state is WeatherLoaded) {
            return _buildWeatherWidget(state.weather);
          } else if (state is WeatherError) {
            return _buildErrorWidget();
          } else {
            return _buildLoadingWidget();
          }
        },
      ),
    );
  }

  Widget _buildWeatherWidget(WeatherEntity weather) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2565),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E3A8A), width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weather.condition,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Probabilidad de lluvia ${weather.rainProbability}%',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2565),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E3A8A), width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Cargando clima...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Obteniendo datos',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2565),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E3A8A), width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Clima perfecto',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Probabilidad de lluvia 20%',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

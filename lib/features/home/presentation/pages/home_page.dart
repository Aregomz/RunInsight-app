// features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:runinsight/features/home/presentation/widgets/badge_summary.dart';
import 'package:runinsight/features/home/presentation/widgets/greeting_header.dart';
import 'package:runinsight/features/home/presentation/widgets/ia_coach_button.dart';
import 'package:runinsight/features/home/presentation/widgets/stats_summary.dart';
import 'package:runinsight/features/home/presentation/widgets/training_button.dart';
import 'package:runinsight/features/home/presentation/widgets/weather_info.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF050510),
              Color(0xFF0A0A20),
              Color(0xFF0C0C27),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              GreetingHeader(username: 'Antonio'), // simulado por ahora
              SizedBox(height: 16),
              BadgeSummary(totalInsignias: 12),
              SizedBox(height: 16),
              WeatherInfoWidget(),
              SizedBox(height: 24),
              TrainingButton(),
              SizedBox(height: 16),
              IACoachButton(),
              SizedBox(height: 32),
              StatsSummary(weeklyKm: 5.2, avgPace: '6:14'),
            ],
          ),
        ),
      ),
    );
  }
}

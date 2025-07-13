import 'package:flutter/material.dart';

class WeatherWidget extends StatelessWidget {
  final String weatherDescription;
  final bool isTrainingStarted;

  const WeatherWidget({
    super.key,
    required this.weatherDescription,
    required this.isTrainingStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFF6A00).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wb_sunny,
            color: const Color(0xFFFF6A00),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            isTrainingStarted ? weatherDescription : 'Clima no disponible',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
} 
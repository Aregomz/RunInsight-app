import 'package:flutter/material.dart';

class StatsSummary extends StatelessWidget {
  final double weeklyKm;
  final String avgPace;

  const StatsSummary({
    super.key,
    required this.weeklyKm,
    required this.avgPace,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF181B23),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.grey[600]!,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  weeklyKm == 0 ? '0.0' : weeklyKm.toString(),
                  style: const TextStyle(
                    color: Color(0xFFFF6A00),
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  weeklyKm == 0 ? 'km esta semana' : 'km esta semana',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                if (weeklyKm == 0) ...[
                  const SizedBox(height: 4),
                  const Text(
                    '¡Comienza a entrenar!',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF181B23),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.grey[600]!,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  avgPace,
                  style: const TextStyle(
                    color: Color(0xFFFF6A00),
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ritmo promedio',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                if (avgPace == '0.0 min/km' || avgPace == '0.00 min/km') ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Sin datos aún',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

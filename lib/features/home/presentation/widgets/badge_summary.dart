import 'package:flutter/material.dart';

class BadgeSummary extends StatelessWidget {
  final int totalInsignias;

  const BadgeSummary({super.key, required this.totalInsignias});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Insignias totales',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalInsignias Insignias',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 249, 230, 59),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.emoji_events,
            color: Color(0xFFFFD700), // Color dorado para la medalla
            size: 54, // Trofeo más grande
          ),
        ],
      ),
    );
  }
}

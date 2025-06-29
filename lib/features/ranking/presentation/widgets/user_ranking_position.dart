import 'package:flutter/material.dart';

class UserRankingPosition extends StatelessWidget {
  final int position;
  final String name;
  final double km;
  final int workouts;

  const UserRankingPosition({
    super.key,
    required this.position,
    required this.name,
    required this.km,
    required this.workouts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2B170B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFF6A00), width: 2),
      ),
      child: Row(
        children: [
          Text(
            '#$position',
            style: const TextStyle(
              color: Color(0xFFFF6A00),
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$workouts Entrenamientos',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${km.toStringAsFixed(1)}km',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

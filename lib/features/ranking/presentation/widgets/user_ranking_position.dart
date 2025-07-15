import 'package:flutter/material.dart';

class UserRankingPosition extends StatelessWidget {
  final int position;
  final String name;
  final double km;
  final int workouts;
  final Color? highlightColor;

  const UserRankingPosition({
    super.key,
    required this.position,
    required this.name,
    required this.km,
    required this.workouts,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = highlightColor ?? const Color(0xFFFF6A00);
    final Color bgColor = (highlightColor != null ? highlightColor!.withOpacity(0.15) : const Color(0xFF2B170B));
    final Color numberColor = highlightColor ?? const Color(0xFFFF6A00);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        children: [
          Text(
            '#$position',
            style: TextStyle(
              color: numberColor,
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

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Insignias totales',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          Row(
            children: [
              Text(
                '$totalInsignias Insignias',
                style: const TextStyle(
                  color: Color(0xFFFF6A00),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 6),
              const Text('🔥', style: TextStyle(fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }
}

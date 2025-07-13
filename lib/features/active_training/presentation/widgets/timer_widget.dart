import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final Duration elapsed;
  final bool isTrainingStarted;

  const TimerWidget({
    super.key,
    required this.elapsed,
    required this.isTrainingStarted,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF6A00).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            color: const Color(0xFFFF6A00),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(elapsed),
            style: const TextStyle(
              color: Color(0xFFFF6A00),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 
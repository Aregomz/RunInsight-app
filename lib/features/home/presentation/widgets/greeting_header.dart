
// features/home/presentation/widgets/greeting_header.dart
import 'package:flutter/material.dart';

class GreetingHeader extends StatelessWidget {
  final String username;

  const GreetingHeader({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hola,',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              Text(
                username,
                style: const TextStyle(
                  color: Color(0xFFFF6A00),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '👋',
                style: TextStyle(fontSize: 24),
              )
            ],
          ),
        ],
      ),
    );
  }
}
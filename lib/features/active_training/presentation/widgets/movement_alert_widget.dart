import 'package:flutter/material.dart';

class MovementAlertWidget extends StatelessWidget {
  final bool showAlert;

  const MovementAlertWidget({
    super.key,
    required this.showAlert,
  });

  @override
  Widget build(BuildContext context) {
    if (!showAlert) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            'Mueve el dispositivo para detectar distancia',
            style: TextStyle(
              color: Colors.blue[300],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
} 
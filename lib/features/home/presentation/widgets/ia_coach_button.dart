import 'package:flutter/material.dart';
import 'package:runinsight/features/auth/presentation/widgets/gradient_button.dart';

class IACoachButton extends StatelessWidget {
  const IACoachButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      onPressed: () {
        // TODO: Implementar navegación al IA Coach
      },
      text: 'IA Coach',
      width: double.infinity,
      colors: const [
        Color(0xFF6366F1), // Azul índigo
        Color(0xFF8B5CF6), // Violeta
      ],
    );
  }
}

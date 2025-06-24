import 'package:flutter/material.dart';
import 'package:runinsight/features/auth/presentation/widgets/gradient_button.dart';

class TrainingButton extends StatelessWidget {
  const TrainingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      onPressed: () {
        // TODO: Implementar navegación al entrenamiento
      },
      text: 'Iniciar Entrenamiento',
      width: double.infinity,
    );
  }
}

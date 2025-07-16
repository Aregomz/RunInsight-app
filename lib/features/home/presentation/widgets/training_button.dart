import 'package:flutter/material.dart';
import 'package:runinsight/features/auth/presentation/widgets/gradient_button.dart';
import 'package:go_router/go_router.dart';

class TrainingButton extends StatelessWidget {
  const TrainingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      onPressed: () {
        context.push('/training_in_progress');
      },
      text: 'Iniciar Entrenamiento',
      width: double.infinity,
    );
  }
}

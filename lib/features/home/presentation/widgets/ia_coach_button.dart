import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runinsight/features/auth/presentation/widgets/gradient_button.dart';
import 'package:runinsight/features/ia_coach/presentation/pages/ia_coach_page.dart';
import 'package:runinsight/features/user/presentation/bloc/user_bloc.dart';
import 'package:runinsight/features/trainings/presentation/bloc/trainings_bloc.dart';
import 'package:runinsight/features/trainings/presentation/bloc/trainings_state.dart';
import 'package:go_router/go_router.dart';

class IACoachButton extends StatelessWidget {
  final Map<String, dynamic> userStats;
  final List<Map<String, dynamic>> lastTrainings;

  IACoachButton({
    Key? key,
    required this.userStats,
    required this.lastTrainings,
  }) : super(key: key) {
    print('IACoachButton: Constructor ejecutado');
  }

  @override
  Widget build(BuildContext context) {
    print('IACoachButton: build ejecutado');
    return GradientButton(
      onPressed: () {
        print('IA Coach button pressed');
        context.push('/ia-coach', extra: {
          'userStats': userStats,
          'lastTrainings': lastTrainings,
        });
      },
      text: 'IA Coach',
      width: double.infinity,
      colors: const [
        Color(0xFF6366F1),
        Color(0xFF8B5CF6),
      ],
    );
  }
}

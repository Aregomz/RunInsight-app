// features/trainings/presentation/pages/trainings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runinsight/features/trainings/presentation/bloc/trainings_bloc.dart';
import 'package:runinsight/features/trainings/presentation/widgets/trainings_list.dart';
import 'package:runinsight/features/trainings/domain/usecases/get_trainings.dart';
import 'package:runinsight/features/trainings/domain/entities/training_entity.dart';
import 'package:runinsight/features/trainings/domain/repositories/trainings_repository.dart';
import 'package:go_router/go_router.dart';

class DummyTrainingsRepository implements TrainingRepository {
  @override
  Future<List<TrainingEntity>> getTrainings() async {
    return [
      TrainingEntity(
        id: '1',
        date: DateTime.now().subtract(const Duration(days: 1)),
        kilometers: 6.2,
        time: '00:34:42',
        pace: '5:35',
        duration: '00:34:42',
        weather: 'Soleado',
        heartRate: 134,
        calories: 290,
      ),
    ];
  }
}

class TrainingsPage extends StatelessWidget {
  const TrainingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrainingsBloc(getTrainings: GetTrainings(DummyTrainingsRepository()))..add(LoadTrainings()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Entrenamientos'),
          backgroundColor: const Color(0xFF0C0C27),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (GoRouter.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
        ),
        backgroundColor: const Color(0xFF0C0C27),
        body: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TrainingsList(),
        ),
      ),
    );
  }
}

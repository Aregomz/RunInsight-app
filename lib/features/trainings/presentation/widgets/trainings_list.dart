// features/trainings/presentation/widgets/trainings_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runinsight/features/trainings/domain/entities/training_entity.dart';
import 'package:runinsight/features/trainings/presentation/bloc/trainings_bloc.dart';
import 'training_card.dart';

class TrainingsList extends StatelessWidget {
  const TrainingsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrainingsBloc, TrainingsState>(
      builder: (context, state) {
        if (state is TrainingsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TrainingsLoaded) {
          if (state.trainings.isEmpty) {
            return const Center(child: Text('No hay entrenamientos')); 
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.trainings.length,
            itemBuilder: (context, index) => TrainingCard(training: state.trainings[index]),
          );
        } else if (state is TrainingsError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
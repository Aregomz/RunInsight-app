// features/active_training/presentation/bloc/active_training_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/active_training_session.dart';
import '../../domain/usecases/start_training.dart';
import '../../domain/usecases/update_training_metrics.dart';
import '../../domain/usecases/finish_training.dart';
import '../../domain/usecases/get_training_summary.dart';

part 'active_training_event.dart';
part 'active_training_state.dart';

class ActiveTrainingBloc extends Bloc<ActiveTrainingEvent, ActiveTrainingState> {
  final StartTraining startTraining;
  final UpdateTrainingMetrics updateTrainingMetrics;
  final FinishTraining finishTraining;
  final GetTrainingSummary getTrainingSummary;

  ActiveTrainingBloc({
    required this.startTraining,
    required this.updateTrainingMetrics,
    required this.finishTraining,
    required this.getTrainingSummary,
  }) : super(ActiveTrainingInitial()) {
    on<StartTrainingRequested>(_onStart);
    on<UpdateMetricsRequested>(_onUpdate);
    on<FinishTrainingRequested>(_onFinish);
    on<GetTrainingSummaryRequested>(_onSummary);
  }

  Future<void> _onStart(StartTrainingRequested event, Emitter<ActiveTrainingState> emit) async {
    emit(ActiveTrainingLoading());
    await startTraining();
    emit(ActiveTrainingInProgress(session: ActiveTrainingSession.empty()));
  }

  void _onUpdate(UpdateMetricsRequested event, Emitter<ActiveTrainingState> emit) {
    if (state is ActiveTrainingInProgress) {
      updateTrainingMetrics(event.session);
      emit(ActiveTrainingInProgress(session: event.session));
    }
  }

  Future<void> _onFinish(FinishTrainingRequested event, Emitter<ActiveTrainingState> emit) async {
    emit(ActiveTrainingLoading());
    await finishTraining();
    final summary = await getTrainingSummary();
    emit(ActiveTrainingCompleted(summary: summary));
  }

  Future<void> _onSummary(GetTrainingSummaryRequested event, Emitter<ActiveTrainingState> emit) async {
    emit(ActiveTrainingLoading());
    final summary = await getTrainingSummary();
    emit(ActiveTrainingCompleted(summary: summary));
  }
}

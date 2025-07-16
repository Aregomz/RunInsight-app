import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/ia_prediction_entity.dart';
import '../../domain/usecases/get_ia_predictions_usecase.dart';

part 'ia_coach_event.dart';
part 'ia_coach_state.dart';

class IaCoachBloc extends Bloc<IaCoachEvent, IaCoachState> {
  final GetIaPredictionsUseCase getPredictions;
  IaCoachBloc({required this.getPredictions}) : super(IaCoachInitial()) {
    on<IaCoachRequested>(_onRequested);
  }

  Future<void> _onRequested(IaCoachRequested event, Emitter<IaCoachState> emit) async {
    emit(IaCoachLoading());
    try {
      final predictions = await getPredictions(
        userStats: event.userStats,
        lastTrainings: event.lastTrainings,
      );
      emit(IaCoachLoaded(predictions));
    } catch (e) {
      emit(IaCoachError(e.toString()));
    }
  }
}

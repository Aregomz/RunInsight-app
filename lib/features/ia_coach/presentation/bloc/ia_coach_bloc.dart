import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'ia_coach_event.dart';
part 'ia_coach_state.dart';

class IaCoachBloc extends Bloc<IaCoachEvent, IaCoachState> {
  IaCoachBloc() : super(IaCoachInitial()) {
    on<IaCoachEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}

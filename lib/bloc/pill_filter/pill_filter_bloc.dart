
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill/pill_state.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/shared_preferences_service.dart';


enum PillFilterEvent {pillsToTake, pillTaken}

class PillsFilterEvent {
  final PillFilterEvent eventName;
  final String date;
  final List<PillToTake>? pillsToTake;
  final List<PillTaken>? pillsTaken;

  PillsFilterEvent({
    required this.eventName,
    required this.date,
    this.pillsToTake,
    this.pillsTaken
  });
}


class PillFilterBloc extends Bloc<PillsFilterEvent, PillState> {
  PillFilterBloc(SharedPreferencesService sharedPreferencesService)
      : super(PillState()) {
    on<PillsFilterEvent>((event, emit) async {
      if (event.eventName == PillFilterEvent.pillsToTake) {
        List<PillTaken> pillsTaken = await sharedPreferencesService
            .getPillsTakenForDate(event.date);
        emit(PillState(
            pillsTaken: pillsTaken,
            pillsToTake: event.pillsToTake
        ));
      } else {
        List<PillToTake> pillsToTake = await sharedPreferencesService
            .getPillsToTakeForDate(event.date);
        emit(PillState(
            pillsTaken: event.pillsTaken,
            pillsToTake: pillsToTake
        ));
      };
    });
  }
}
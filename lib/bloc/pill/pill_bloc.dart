import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:pill/bloc/pill/pill_state.dart';
import 'package:pill/model/pill_to_take.dart';

enum PillEvent {
  addPill,
  removePill,
  updatePill,
  loadPills,
}

class PillsEvent {
  final PillEvent eventName;
  final String date;
  final PillToTake? pillToTake;
  final List<PillToTake>? pillsToTake;
  final List<PillTaken>? pillsTaken;
  final DateTime? startDateTime;

  PillsEvent(
      {required this.eventName,
      required this.date,
      this.pillToTake,
      this.pillsToTake,
      this.pillsTaken,
      this.startDateTime});
}

class PillBloc extends Bloc<PillsEvent, PillState> {
  PillBloc(SharedPreferencesService sharedPreferencesService)
      : super(PillState()) {
    on<PillsEvent>((event, emit) {
      switch (event.eventName) {
        case PillEvent.addPill:
          _onAddPill(event, emit, sharedPreferencesService);
          break;
        case PillEvent.removePill:
          _onRemovePill(event, emit, sharedPreferencesService);
          break;
        case PillEvent.updatePill:
          _onUpdatePill(event, emit, sharedPreferencesService);
          break;
        case PillEvent.loadPills:
          final pillsTaken =
              sharedPreferencesService.getPillsTakenForDate(event.date);
          final pillsToTake =
              sharedPreferencesService.getPillsToTakeForDate(event.date);
          emit(PillState(pillsToTake: pillsToTake, pillsTaken: pillsTaken));
          break;
      }
    });
  }

  void _onAddPill(PillsEvent event, Emitter<PillState> emitter,
      SharedPreferencesService sharedPreferencesService) {
    final pillToTake = event.pillToTake;
    if (pillToTake == null) return;

    // addPillToDates writes to all scheduled dates. We then read back
    // event.date specifically so the emitted state always reflects the
    // correct day's list, regardless of how many days the pill spans.
    sharedPreferencesService.addPillToDates(
        event.startDateTime ?? DateTime.now(), pillToTake);

    final pillsToTake =
        sharedPreferencesService.getPillsToTakeForDate(event.date);

    emitter(PillState(
      pillsToTake: pillsToTake,
      pillsTaken: state.pillsTaken,
    ));
  }

  void _onRemovePill(PillsEvent event, Emitter<PillState> emitter,
      SharedPreferencesService sharedPreferencesService) {
    final pillToTake = event.pillToTake;
    if (pillToTake == null) return;

    final updatedPills =
        sharedPreferencesService.removePillFromDate(pillToTake, event.date);

    emitter(PillState(
      pillsToTake: updatedPills,
      pillsTaken: state.pillsTaken,
    ));
  }

  void _onUpdatePill(PillsEvent event, Emitter<PillState> emitter,
      SharedPreferencesService sharedPreferencesService) {
    final pillToTake = event.pillToTake;
    if (pillToTake == null) return;

    final result =
        sharedPreferencesService.updatePillForDate(pillToTake, event.date);

    emitter(PillState(
      pillsToTake: result.pillsToTake,
      pillsTaken: result.pillsTaken,
    ));
  }
}

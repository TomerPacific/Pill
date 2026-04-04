import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/service/date_service.dart';
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
  final SharedPreferencesService _sharedPreferencesService;
  final DateService _dateService;

  PillBloc(this._sharedPreferencesService, this._dateService)
      : super(PillState()) {
    on<PillsEvent>((event, emit) {
      switch (event.eventName) {
        case PillEvent.addPill:
          _onAddPill(event, emit);
          break;
        case PillEvent.removePill:
          _onRemovePill(event, emit);
          break;
        case PillEvent.updatePill:
          _onUpdatePill(event, emit);
          break;
        case PillEvent.loadPills:
          final pillsTaken =
              _sharedPreferencesService.getPillsTakenForDate(event.date);
          final pillsToTake =
              _sharedPreferencesService.getPillsToTakeForDate(event.date);
          emit(PillState(pillsToTake: pillsToTake, pillsTaken: pillsTaken));
          break;
      }
    });
  }

  void _onAddPill(PillsEvent event, Emitter<PillState> emitter) {
    final pillToTake = event.pillToTake;
    if (pillToTake == null) return;

    // addPillToDates writes to all scheduled dates. We then read back
    // event.date specifically so the emitted state always reflects the
    // correct day's list, regardless of how many days the pill spans.
    _sharedPreferencesService.addPillToDates(
        event.startDateTime ?? _dateService.now(), pillToTake);

    final pillsToTake =
        _sharedPreferencesService.getPillsToTakeForDate(event.date);

    emitter(PillState(
      pillsToTake: pillsToTake,
      pillsTaken: state.pillsTaken,
    ));
  }

  void _onRemovePill(PillsEvent event, Emitter<PillState> emitter) {
    final pillToTake = event.pillToTake;
    if (pillToTake == null) return;

    final updatedPills =
        _sharedPreferencesService.removePillFromDate(pillToTake, event.date);

    emitter(PillState(
      pillsToTake: updatedPills,
      pillsTaken: state.pillsTaken,
    ));
  }

  void _onUpdatePill(PillsEvent event, Emitter<PillState> emitter) {
    final pillToTake = event.pillToTake;
    if (pillToTake == null) return;

    final result =
        _sharedPreferencesService.updatePillForDate(pillToTake, event.date);

    if (result == null) return;

    emitter(PillState(
      pillsToTake: result.pillsToTake,
      pillsTaken: result.pillsTaken,
    ));
  }
}

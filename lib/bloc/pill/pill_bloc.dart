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

    // addPillToDates now returns the updated list — no need to re-read.
    final updatedPillsToTake = sharedPreferencesService.addPillToDates(
        event.startDateTime ?? DateTime.now(), pillToTake);

    emitter(PillState(
      pillsToTake: updatedPillsToTake,
      pillsTaken: state.pillsTaken,
    ));
  }

  void _onRemovePill(PillsEvent event, Emitter<PillState> emitter,
      SharedPreferencesService sharedPreferencesService) {
    final pillToTake = event.pillToTake;
    final pillsToTakeList = event.pillsToTake;
    if (pillToTake == null || pillsToTakeList == null) return;

    // removePillFromDate now returns the updated list — no need to re-read.
    final updatedPills = sharedPreferencesService
        .removePillFromDate(pillToTake, event.date);

    emitter(PillState(
      pillsToTake: updatedPills,
      pillsTaken: event.pillsTaken,
    ));
  }

  void _onUpdatePill(PillsEvent event, Emitter<PillState> emitter,
      SharedPreferencesService sharedPreferencesService) {
    final pillToTake = event.pillToTake;
    if (pillToTake == null) return;

    // updatePillForDate now returns both updated lists — no need to re-read.
    final result = sharedPreferencesService
        .updatePillForDate(pillToTake, event.date);

    emitter(PillState(
      pillsToTake: result.pillsToTake,
      pillsTaken: result.pillsTaken,
    ));
  }
}
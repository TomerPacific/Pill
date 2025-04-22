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

  PillsEvent(
      {required this.eventName,
      required this.date,
      this.pillToTake,
      this.pillsToTake,
      this.pillsTaken});
}

class PillBloc extends Bloc<PillsEvent, PillState> {
  PillBloc(SharedPreferencesService sharedPreferencesService)
      : super(PillState()) {
    on<PillsEvent>((event, emit) async {
      switch (event.eventName) {
        case PillEvent.addPill:
          await _onAddPill(event, emit, sharedPreferencesService);
          break;
        case PillEvent.removePill:
          await _onRemovePill(event, emit, sharedPreferencesService);
          break;
        case PillEvent.updatePill:
          await _onUpdatePill(event, emit, sharedPreferencesService);
          break;
        case PillEvent.loadPills:
          List<PillTaken> pillsTaken =
              await sharedPreferencesService.getPillsTakenForDate(event.date);
          List<PillToTake> pillsToTake =
              await sharedPreferencesService.getPillsToTakeForDate(event.date);
          emit(
            PillState(pillsToTake: pillsToTake, pillsTaken: pillsTaken),
          );
          break;
      }
    });
  }

  Future<void> _onAddPill(PillsEvent event, Emitter<PillState> emitter,
      SharedPreferencesService sharedPreferencesService) async {
    PillToTake? pillToTake = event.pillToTake;

    if (pillToTake == null) {
      return;
    }

    List<PillToTake> pillsToTake =
        await sharedPreferencesService.getPillsToTakeForDate(event.date);
    List<PillToTake> pills = List.from(pillsToTake)..add(pillToTake);
    sharedPreferencesService.addPillToDates(event.date, pillToTake);
    emitter(new PillState(pillsToTake: pills, pillsTaken: state.pillsTaken));
  }

  Future<void> _onRemovePill(PillsEvent event, Emitter<PillState> emitter,
      SharedPreferencesService sharedPreferencesService) async {

    PillToTake? pillToTake = event.pillToTake;
    List<PillToTake>? pillsToTake = event.pillsToTake;

    if (pillToTake == null || pillsToTake == null) {
      return;
    }

    await sharedPreferencesService.removePillFromDate(
        pillToTake, event.date);
    List<PillToTake> updatedPills = pillsToTake
        .where((pill) => !pill.equals(pillToTake))
        .toList();
    emitter(
      PillState(pillsToTake: updatedPills, pillsTaken: event.pillsTaken),
    );
  }

  Future<void> _onUpdatePill(PillsEvent event, Emitter<PillState> emitter,
      SharedPreferencesService sharedPreferencesService) async {
    List<PillToTake> pillsToTake =
        await sharedPreferencesService.getPillsToTakeForDate(event.date);

    PillToTake storedPill = pillsToTake
        .firstWhere((pill) => pill.pillName == event.pillToTake!.pillName);
    pillsToTake.remove(storedPill);

    storedPill.lastTaken = event.pillToTake!.lastTaken;
    storedPill.pillRegiment = event.pillToTake!.pillRegiment;

    if (storedPill.pillRegiment != 0) {
      pillsToTake.add(storedPill);
    }

    await sharedPreferencesService.updatePillForDate(storedPill, event.date);

    List<PillTaken> pillsTaken =
        await sharedPreferencesService.getPillsTakenForDate(event.date);
    emitter(
      PillState(pillsToTake: pillsToTake, pillsTaken: pillsTaken),
    );
  }
}

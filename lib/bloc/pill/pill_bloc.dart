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
          List<PillTaken> pillsTaken =
              sharedPreferencesService.getPillsTakenForDate(event.date);
          List<PillToTake> pillsToTake =
              sharedPreferencesService.getPillsToTakeForDate(event.date);
          emit(
            PillState(pillsToTake: pillsToTake, pillsTaken: pillsTaken),
          );
          break;
      }
    });
  }

  void _onAddPill(PillsEvent event, Emitter<PillState> emitter,
      SharedPreferencesService sharedPreferencesService) {
    PillToTake? pillToTake = event.pillToTake;

    if (pillToTake == null) {
      return;
    }

    List<PillToTake> pillsToTakeList =
        sharedPreferencesService.getPillsToTakeForDate(event.date);
    List<PillToTake> pills = List.from(pillsToTakeList)..add(pillToTake);
    sharedPreferencesService.addPillToDates(
        event.startDateTime ?? DateTime.now(), pillToTake);
    emitter(PillState(pillsToTake: pills, pillsTaken: state.pillsTaken));
  }

  void _onRemovePill(PillsEvent event, Emitter<PillState> emitter,
      SharedPreferencesService sharedPreferencesService) {
    PillToTake? pillToTake = event.pillToTake;
    List<PillToTake>? pillsToTakeList = event.pillsToTake;

    if (pillToTake == null || pillsToTakeList == null) {
      return;
    }

    sharedPreferencesService.removePillFromDate(pillToTake, event.date);
    
    final normalizedName = pillToTake.pillName.trim().toLowerCase();
    List<PillToTake> updatedPills = pillsToTakeList
        .where((pill) => pill.pillName.trim().toLowerCase() != normalizedName)
        .toList();
        
    emitter(
      PillState(pillsToTake: updatedPills, pillsTaken: event.pillsTaken),
    );
  }

  void _onUpdatePill(PillsEvent event, Emitter<PillState> emitter,
      SharedPreferencesService sharedPreferencesService) {
    PillToTake? pillToTake = event.pillToTake;

    if (pillToTake == null) {
      return;
    }

    // Always update the service first to handle persistence
    // Service handles in-place replacement and potentially removing if regiment is 0
    sharedPreferencesService.updatePillForDate(pillToTake, event.date);

    // Reload from service to ensure consistent ordering and state with persistence
    List<PillToTake> pillsToTakeList = sharedPreferencesService.getPillsToTakeForDate(event.date);
    List<PillTaken> pillsTakenList = sharedPreferencesService.getPillsTakenForDate(event.date);

    emitter(
      PillState(pillsToTake: pillsToTakeList, pillsTaken: pillsTakenList),
    );
  }
}

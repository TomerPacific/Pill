
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:pill/bloc/pill/pill_state.dart';
import 'package:pill/model/pill_to_take.dart';


enum PillEvent {addPill, removePill, updatePill, loadTakenPills, loadPillsToTake}

class PillsEvent {
  final PillEvent eventName;
  final String date;
  final PillToTake? pillToTake;
  final List<PillToTake>? pillsToTake;
  final List<PillTaken>? pillsTaken;

  PillsEvent({
    required this.eventName,
    required this.date,
    this.pillToTake,
    this.pillsToTake,
    this.pillsTaken
  });
}


class PillBloc extends Bloc<PillsEvent, PillState> {
  PillBloc(SharedPreferencesService sharedPreferencesService) : super(
    PillState()
  ) {
    on<PillsEvent>((event, emit) async {
      switch(event.eventName) {
        case PillEvent.addPill:
          _onAddPill(event, emit, sharedPreferencesService);
          break;
        case PillEvent.removePill:
          _onDeletePill(event, emit, sharedPreferencesService);
          break;
        case PillEvent.updatePill:

          List<PillToTake> pillsToTake = await sharedPreferencesService.getPillsToTakeForDate(event.date);

          PillToTake storedPill = pillsToTake.firstWhere((pill) => pill.pillName == event.pillToTake!.pillName);
          pillsToTake.remove(storedPill);

          storedPill.lastTaken = event.pillToTake!.lastTaken;
          storedPill.pillRegiment = event.pillToTake!.pillRegiment;

          if (storedPill.pillRegiment != 0) {
            pillsToTake.add(storedPill);
          }

          sharedPreferencesService.updatePillForDate(storedPill, event.date);

          List<PillTaken> pillsTaken = await sharedPreferencesService.getPillsTakenForDate(event.date);
          emit(PillState(
              pillsToTake: pillsToTake,
              pillsTaken: pillsTaken),
          );
          break;
        case PillEvent.loadPillsToTake:
          List<PillToTake> pillsToTake = await sharedPreferencesService.getPillsToTakeForDate(event.date);

          emit(PillState(
              pillsToTake: pillsToTake,
              pillsTaken: null),
          );
          break;
        case PillEvent.loadTakenPills:
          List<PillTaken> pillsTaken = await sharedPreferencesService.getPillsTakenForDate(event.date);

          emit(PillState(
              pillsToTake: null,
              pillsTaken: pillsTaken),
          );
          break;
      }
    });
  }

  void _onAddPill(PillsEvent event, Emitter<PillState> emitter, SharedPreferencesService sharedPreferencesService) async {
    List<PillToTake> pillsToTake = await sharedPreferencesService.getPillsToTakeForDate(event.date);
    List<PillToTake> pills = List.from(pillsToTake)..add(event.pillToTake!);
    sharedPreferencesService.addPillToDates(event.date, event.pillToTake!);
    emitter(new PillState(
        pillsToTake: pills,
        pillsTaken: state.pillsTaken
      )
    );
  }

  void _onDeletePill(
      PillsEvent event,
      Emitter<PillState> emitter,
      SharedPreferencesService sharedPreferencesService) async {
    List<PillToTake> updatedPills = event.pillsToTake!.where((pill) => !pill.equals(event.pillToTake!)).toList();
    String date = DateService().getCurrentDateAsMonthAndDay();
    List<PillTaken> pillsTaken = await sharedPreferencesService.getPillsTakenForDate(date);
    emitter(PillState(
        pillsToTake: updatedPills,
        pillsTaken: pillsTaken),
    );
  }

}
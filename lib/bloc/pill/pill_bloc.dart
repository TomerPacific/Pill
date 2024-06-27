
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:pill/bloc/pill/pill_state.dart';
import 'package:pill/model/pill_to_take.dart';


enum PillEvent {loadPills, addPill, removePill, updatePill}

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
        case PillEvent.loadPills:
          List<PillToTake> pillsToTake = await sharedPreferencesService.getPillsToTakeForDate(event.date);
          List<PillTaken> pillsTaken = await sharedPreferencesService.getPillsTakenForDate(event.date);
          emit(new PillState(
              pillsToTake: pillsToTake,
              pillsTaken: pillsTaken),
          );
          break;
        case PillEvent.addPill:
          _onAddPill(event, emit, sharedPreferencesService);
          break;
        case PillEvent.removePill:
          _onDeletePill(event, emit, sharedPreferencesService);
          break;
        case PillEvent.updatePill:
          _onUpdatePill(event, emit, sharedPreferencesService);
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

  void _onUpdatePill(
      PillsEvent event,
      Emitter<PillState> emitter,
      SharedPreferencesService sharedPreferencesService) async {

      List<PillToTake> updatedPills;
      if (event.pillToTake!.pillRegiment == 0) {
        updatedPills = event.pillsToTake!.where((pill) => !pill.equals(event.pillToTake!)).toList();
      } else {
        updatedPills = event.pillsToTake!.map((pill) =>
        pill.equals(event.pillToTake!)
            ? event.pillToTake!
            : pill).toList();
      }

    String date = DateService().getCurrentDateAsMonthAndDay();
    List<PillTaken> pillsTaken = await sharedPreferencesService.getPillsTakenForDate(date);
    emitter(PillState(
        pillsToTake: updatedPills,
        pillsTaken: pillsTaken),
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
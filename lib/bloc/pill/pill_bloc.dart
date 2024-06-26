
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:pill/bloc/pill/pill_state.dart';
import 'package:pill/model/pill_to_take.dart';


enum PillEvent {loadPills, addPill, removePill, updatePill}

class PillsEvent {
  final PillEvent eventName;
  final PillToTake? pillToTake;
  final List<PillToTake>? pillsToTake;
  final List<PillTaken>? pillsTaken;

  PillsEvent({
    required this.eventName,
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
          _onLoadPills(event, emit);
          break;
        case PillEvent.addPill:
          _onAddPill(event, emit);
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

  void _onLoadPills(PillsEvent event, Emitter<PillState> emitter) {
    if (event.pillsTaken != null && event.pillsToTake != null) {
      emitter(new PillState(
          pillsToTake: event.pillsToTake!,
          pillsTaken: event.pillsTaken!),
      );
    }
  }

  void _onAddPill(PillsEvent event, Emitter<PillState> emitter) {
    emitter(new PillState(
        pillsToTake: List.from(event.pillsToTake!)..add(event.pillToTake!),
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

  void _onDeletePill(PillsEvent event, Emitter<PillState> emitter, SharedPreferencesService sharedPreferencesService) async {
    List<PillToTake> updatedPills = state.pillsToTake!.where((pill) => !pill.equals(event.pillToTake!)).toList();
    String date = DateService().getCurrentDateAsMonthAndDay();
    List<PillTaken> pillsTaken = await sharedPreferencesService.getPillsTakenForDate(date);
    emitter(PillState(
        pillsToTake: updatedPills,
        pillsTaken: pillsTaken),
    );
  }

}
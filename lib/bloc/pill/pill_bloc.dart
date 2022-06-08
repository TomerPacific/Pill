
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'pill_event.dart';
import 'package:pill/bloc/pill/pill_state.dart';
import 'package:pill/model/pill_to_take.dart';

class PillBloc extends Bloc<PillEvent, PillState> {
  PillBloc() : super(PillLoading()) {
    on<LoadPill>(_onLoadPills);
    on<AddPill>(_onAddPill);
    on<UpdatePill>(_onUpdatePill);
    on<DeletePill>(_onDeletePill);
  }

  void _onLoadPills(LoadPill event, Emitter<PillState> emitter) {
    emitter(PillLoaded(
        pillsToTake: event.pillsToTake,
        pillsTaken: event.pillsTaken), );
  }

  void _onAddPill(AddPill event, Emitter<PillState> emitter) {
    final state = this.state;
    if (state is PillLoaded) {
      emitter(PillLoaded(
          pillsToTake: List.from(state.pillsToTake)..add(event.pillToTake),
          pillsTaken: state.pillsTaken
        )
      );
    }
  }

  void _onUpdatePill(UpdatePill event, Emitter<PillState> emitter) {
    final state = this.state;
    if (state is PillLoaded) {
      List<PillToTake> updatedPills;
      if (event.pillToTake.pillRegiment == 0) {
        updatedPills = state.pillsToTake.where((pill) => !pill.equals(event.pillToTake)).toList();
      } else {
        updatedPills = state.pillsToTake.map((pill) =>
        pill.equals(event.pillToTake)
            ? event.pillToTake
            : pill).toList();
      }

    String date = DateService().getCurrentDateAsMonthAndDay();
    List<PillTaken> pillsTaken = SharedPreferencesService().getPillsTakenForDate(date);
    emitter(PillLoaded(
        pillsToTake: updatedPills,
        pillsTaken: pillsTaken),
    );
    }
  }

  void _onDeletePill(DeletePill event, Emitter<PillState> emitter) {
    final state = this.state;
    if (state is PillLoaded) {
      List<PillToTake> updatedPills = state.pillsToTake.where((pill) => !pill.equals(event.pillToTake)).toList();
      String date = DateService().getCurrentDateAsMonthAndDay();
      List<PillTaken> pillsTaken = SharedPreferencesService().getPillsTakenForDate(date);
      emitter(PillLoaded(
          pillsToTake: updatedPills,
          pillsTaken: pillsTaken),
      );
    }
  }

}
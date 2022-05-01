
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/model/PillToTake.dart';

import 'PillEvent.dart';
import 'PillState.dart';

class PillBloc extends Bloc<PillEvent, PillState> {
  PillBloc() : super(PillLoading()) {
    on<LoadPill>(_onLoadPills);
    on<AddPill>(_onAddPill);
    on<UpdatePill>(_onUpdatePill);
    on<DeletePill>(_onDeletePill);
  }

  void _onLoadPills(LoadPill event, Emitter<PillState> emitter) {
    emitter(PillLoaded(pillsToTake: event.pillsToTake), );
  }

  void _onAddPill(AddPill event, Emitter<PillState> emitter) {
    final state = this.state;
    if (state is PillLoaded) {
      emitter(PillLoaded(pillsToTake: List.from(state.pillsToTake)..add(event.pillToTake),
        )
      );
    }
  }

  void _onUpdatePill(UpdatePill event, Emitter<PillState> emitter) {
    final state = this.state;
    if (state is PillLoaded) {
    List<PillToTake> updatedPills = state.pillsToTake.map((pill) => pill.equals(event.pillToTake) ? event.pillToTake : pill).toList();
        emitter(PillLoaded(pillsToTake: updatedPills),
        );
    }
  }

  void _onDeletePill(DeletePill event, Emitter<PillState> emitter) {
    final state = this.state;
    if (state is PillLoaded) {
      List<PillToTake> updatedPills = state.pillsToTake.where((pill) => !pill.equals(event.pillToTake)).toList();
      emitter(PillLoaded(pillsToTake: updatedPills),
      );
    }
  }

}
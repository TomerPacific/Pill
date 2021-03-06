
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/bloc/pill/pill_state.dart';
import 'package:pill/bloc/pill_filter/pill_filter_event.dart';
import 'package:pill/bloc/pill_filter/pill_filter_state.dart';
import 'package:pill/model/pill_filter.dart';

class PillFilterBloc extends Bloc<PillFilterEvent, PillFilterState> {
  final PillBloc _pillBloc;

  PillFilterBloc({ required PillBloc pillBloc }) :
        _pillBloc = pillBloc,
        super(PillFilterLoading()) {
    on<UpdatePills>(_onUpdatePills);
    on<UpdateFilter>(_onUpdateFiler);

    pillBloc.stream.listen((state) {
      add(const UpdateFilter(),);
    });
  }

  void _onUpdatePills(UpdatePills event, Emitter<PillFilterState> emitter) {
    final state = _pillBloc.state;

    if (state is PillLoaded) {
      List<dynamic> pills = [];
      switch(event.pillFilter) {
        case PillFilter.all:
          pills = state.pillsToTake;
          break;
        case PillFilter.taken:
          pills = state.pillsTaken;
          break;
      }

      emitter(
          PillFilterLoaded(filteredPills: pills)
      );
    }
  }

  void _onUpdateFiler(UpdateFilter event, Emitter<PillFilterState> emitter) {
      if (state is PillFilterLoading) {
        add(
          const UpdatePills(pillFilter: PillFilter.all),
        );
      }

      if (state is PillFilterLoaded) {
        final state = this.state as PillFilterLoaded;
        add(
           UpdatePills(pillFilter: state.pillFilter)
        );
      }
  }
}
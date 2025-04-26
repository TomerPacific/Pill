import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/service/shared_preferences_service.dart';

enum ClearPillsEvent { UpdatePillsStatus, ClearAllPills }

class ClearPillsBloc extends Bloc<ClearPillsEvent, bool> {
  ClearPillsBloc(SharedPreferencesService sharedPreferencesService)
      : super(false) {
    on<ClearPillsEvent>((event, emit) {
      switch (event) {
        case ClearPillsEvent.UpdatePillsStatus:
          bool anyPillsLeftToTake =
          sharedPreferencesService.areThereAnyPillsToTake();
          emit(anyPillsLeftToTake);
          break;
        case ClearPillsEvent.ClearAllPills:
          sharedPreferencesService.clearAllPills();
          emit(false);
          break;
      }
    });
  }
}

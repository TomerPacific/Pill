import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/service/shared_preferences_service.dart';

enum ClearPillsEvent { UpdatePillsStatus, ClearAllPills }

class ClearPillsBloc extends Bloc<ClearPillsEvent, bool> {
  ClearPillsBloc(SharedPreferencesService sharedPreferencesService)
      : super(false) {
    on<ClearPillsEvent>((event, emit) async {
      switch (event) {
        case ClearPillsEvent.UpdatePillsStatus:
          bool anyPillsLeftToTake =
              await sharedPreferencesService.areThereAnyPillsToTake();
          emit(anyPillsLeftToTake);
          break;
        case ClearPillsEvent.ClearAllPills:
          await sharedPreferencesService.clearAllPills();
          emit(false);
          break;
      }
    });
  }
}

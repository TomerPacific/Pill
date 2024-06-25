import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/service/shared_preferences_service.dart';

enum ClearPillsEvent { Init, ClearedPills }

class ClearPillsBloc extends Bloc<ClearPillsEvent, bool> {
  ClearPillsBloc(SharedPreferencesService sharedPreferencesService) : super(false) {
    on<ClearPillsEvent>((event, emit) async {
      if (event == ClearPillsEvent.Init) {
        bool anyPillsLeftToTake = await sharedPreferencesService.areThereAnyPillsToTake();
        emit(anyPillsLeftToTake);
      }
      if (event == ClearPillsEvent.ClearedPills) {
        sharedPreferencesService.clearAllPills();
        emit(false);
      }
    });
  }
}
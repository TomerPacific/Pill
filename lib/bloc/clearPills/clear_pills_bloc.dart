import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/service/shared_preferences_service.dart';

enum ClearPillsEvent { updatePillsStatus, clearAllPills }

class ClearPillsBloc extends Bloc<ClearPillsEvent, bool> {
  ClearPillsBloc(SharedPreferencesService sharedPreferencesService)
      : super(false) {
    on<ClearPillsEvent>(
      (event, emit) async {
        switch (event) {
          case ClearPillsEvent.updatePillsStatus:
            bool anyPillsLeftToTake =
                sharedPreferencesService.areThereAnyPillsToTake();
            emit(anyPillsLeftToTake);
            break;
          case ClearPillsEvent.clearAllPills:
            await sharedPreferencesService.clearAllPills();
            emit(sharedPreferencesService.areThereAnyPillsToTake());
            break;
        }
      },
      transformer: sequential(),
    );
  }
}

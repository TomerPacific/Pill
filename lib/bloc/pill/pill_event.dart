
import 'package:pill/model/pill_taken.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';

abstract class PillEvent {
  const PillEvent();

  List<Object> get props => [];
}

class LoadPill extends PillEvent {
  List<PillToTake> pillsToTake;
  List<PillTaken> pillsTaken;

  LoadPill({this.pillsToTake = const <PillToTake>[], this.pillsTaken = const <PillTaken>[]}) {
    String date = DateService().getCurrentDateAsMonthAndDay();
    pillsToTake = SharedPreferencesService().getPillsToTakeForDate(date);
    pillsTaken = SharedPreferencesService().getPillsTakenForDate(date);
  }

  @override
  List<Object> get props => [pillsToTake];
}

class AddPill extends PillEvent {
  final PillToTake pillToTake;

  AddPill({required this.pillToTake}) {
    SharedPreferencesService().addPillToDates(
        DateService().getCurrentDateAsMonthAndDay(), pillToTake);
  }

  @override
  List<Object> get props => [pillToTake];
}

class UpdatePill extends PillEvent {
  final PillToTake pillToTake;

  UpdatePill({required this.pillToTake}) {
    SharedPreferencesService().updatePillForDate(pillToTake, DateService().getCurrentDateAsMonthAndDay());
  }

  @override
  List<Object> get props => [pillToTake];
}

class DeletePill extends PillEvent {
  final PillToTake pillToTake;

  DeletePill({required this.pillToTake}) {
    SharedPreferencesService().removePillFromDate(pillToTake, DateService().getCurrentDateAsMonthAndDay());
  }

  @override
  List<Object> get props => [pillToTake];
}

class ClearAllPills extends PillEvent {
  ClearAllPills() {
    SharedPreferencesService().clearAllPills();
  }
}
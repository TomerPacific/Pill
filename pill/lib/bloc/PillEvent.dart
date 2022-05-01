
import 'package:pill/model/PillToTake.dart';
import 'package:pill/service/DateService.dart';
import 'package:pill/service/SharedPreferencesService.dart';

abstract class PillEvent {
  const PillEvent();

  @override
  List<Object> get props => [];
}

class LoadPill extends PillEvent {
  List<PillToTake> pillsToTake;

  LoadPill({this.pillsToTake = const <PillToTake>[]}) {
    DateTime date = DateTime.now();
    String converted = DateService().getDateAsMonthAndDay(date);
    pillsToTake = SharedPreferencesService().getPillsToTakeForDate(converted);
  }

  @override
  List<Object> get props => [pillsToTake];
}

class AddPill extends PillEvent {
  final PillToTake pillToTake;

  AddPill({required this.pillToTake}) {
    DateTime date = DateTime.now();
    SharedPreferencesService().addPillToDates(
        DateService().getDateAsMonthAndDay(date), pillToTake);
  }

  @override
  List<Object> get props => [pillToTake];
}

class UpdatePill extends PillEvent {
  final PillToTake pillToTake;

  UpdatePill({required this.pillToTake}) {
    DateTime date = DateTime.now();
    String converted = DateService().getDateAsMonthAndDay(date);
    SharedPreferencesService().updatePillForDate(pillToTake, converted);
  }

  @override
  List<Object> get props => [pillToTake];
}

class DeletePill extends PillEvent {
  final PillToTake pillToTake;

  DeletePill({required this.pillToTake}) {
    DateTime date = DateTime.now();
    String converted = DateService().getDateAsMonthAndDay(date);
    SharedPreferencesService().removePillFromDate(pillToTake, converted);
  }

  @override
  List<Object> get props => [pillToTake];
}
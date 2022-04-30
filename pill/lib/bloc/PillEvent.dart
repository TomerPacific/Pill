
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

  const AddPill({required this.pillToTake});

  @override
  List<Object> get props => [pillToTake];
}

class UpdatePill extends PillEvent {
  final PillToTake pillToTake;

  const UpdatePill({required this.pillToTake});

  @override
  List<Object> get props => [pillToTake];
}

class DeletePill extends PillEvent {
  final PillToTake pillToTake;

  const DeletePill({required this.pillToTake});

  @override
  List<Object> get props => [pillToTake];
}
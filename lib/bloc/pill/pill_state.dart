
import 'package:pill/model/pill_taken.dart';
import 'package:pill/model/pill_to_take.dart';

abstract class PillState {
  const PillState();

  List<Object> get props => [];
}

class PillLoading extends PillState {}

class PillLoaded extends PillState {
  final List<PillToTake> pillsToTake;
  final List<PillTaken> pillsTaken;

  const PillLoaded({this.pillsToTake = const <PillToTake>[], this.pillsTaken = const <PillTaken>[]});

  List<Object> get props => [pillsToTake, pillsTaken];
}
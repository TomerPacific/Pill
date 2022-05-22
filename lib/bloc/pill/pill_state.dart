
import 'package:pill/model/pill_to_take.dart';

abstract class PillState {
  const PillState();

  List<Object> get props => [];
}

class PillLoading extends PillState {}

class PillLoaded extends PillState {
  final List<PillToTake> pillsToTake;
  final List<PillToTake> pillsTaken;

  const PillLoaded({this.pillsToTake = const <PillToTake>[], this.pillsTaken = const <PillToTake>[]});

  List<Object> get props => [pillsToTake, pillsTaken];
}
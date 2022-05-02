
import 'package:pill/model/PillToTake.dart';

abstract class PillState {
  const PillState();

  List<Object> get props => [];
}

class PillLoading extends PillState {}

class PillLoaded extends PillState {
  final List<PillToTake> pillsToTake;

  const PillLoaded({this.pillsToTake = const <PillToTake>[]});

  List<Object> get props => [pillsToTake];
}
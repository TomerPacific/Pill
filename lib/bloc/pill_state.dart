
import 'package:pill/model/pill_to_take.dart';

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
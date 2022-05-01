
import 'package:pill/model/PillToTake.dart';

abstract class PillState {
  const PillState();

  @override
  List<Object> get props => [];
}

class PillLoading extends PillState {}

class PillLoaded extends PillState {
  final List<PillToTake> pillsToTake;

  const PillLoaded({this.pillsToTake = const <PillToTake>[]});

  @override
  List<Object> get props => [pillsToTake];
}
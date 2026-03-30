import 'package:equatable/equatable.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/model/pill_to_take.dart';

class PillState extends Equatable {
  final List<PillToTake>? pillsToTake;
  final List<PillTaken>? pillsTaken;
  final PillToTake? pillToTake;

  PillState({
    List<PillToTake>? pillsToTake,
    List<PillTaken>? pillsTaken,
    this.pillToTake,
  })  : pillsToTake = pillsToTake != null ? List.unmodifiable(pillsToTake) : null,
        pillsTaken = pillsTaken != null ? List.unmodifiable(pillsTaken) : null;

  @override
  List<Object?> get props => [pillsToTake, pillsTaken, pillToTake];
}

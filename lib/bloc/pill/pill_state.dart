import 'package:equatable/equatable.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/model/pill_to_take.dart';

class PillState extends Equatable {
  final List<PillToTake>? pillsToTake;
  final List<PillTaken>? pillsTaken;
  final PillToTake? pillToTake;

  const PillState({this.pillsToTake, this.pillsTaken, this.pillToTake});

  @override
  List<Object?> get props => [pillsToTake, pillsTaken, pillToTake];
}

import 'package:pill/model/pill_taken.dart';
import 'package:pill/model/pill_to_take.dart';

class PillState {
  final List<PillToTake>? pillsToTake;
  final List<PillTaken>? pillsTaken;
  final PillToTake? pillToTake;

  const PillState({this.pillsToTake, this.pillsTaken, this.pillToTake});
}

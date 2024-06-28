

import 'package:pill/model/pill_taken.dart';
import 'package:pill/model/pill_to_take.dart';

class PillFilterState {
  final List<PillToTake>? pillsToTake;
  final List<PillTaken>? pillsTaken;

  PillFilterState({
    this.pillsToTake,
    this.pillsTaken,
  });

}
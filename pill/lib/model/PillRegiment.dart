import 'package:flutter/foundation.dart';

enum PillRegiment {
  DAILY,
  WEEKLY,
  MONTHLY
}

class PillRegimentHelper {
  static PillRegiment getPillRegiment(dynamic pillRegimentObject) {
    return PillRegiment.values.firstWhere((element) => describeEnum(element) == pillRegimentObject);
  }
}

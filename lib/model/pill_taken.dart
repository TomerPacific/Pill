import 'dart:convert';

import 'package:pill/constants.dart';
import 'package:pill/model/pill_to_take.dart';

class PillTaken {
  String pillName;
  double pillWeight;
  String pillImage = 'assets/images/defaultPill.png';
  String description;
  DateTime? lastTaken;

  PillTaken(
      {required this.pillName,
      required this.pillWeight,
      required this.description,
      required this.lastTaken});

  factory PillTaken.fromJson(Map<String, dynamic> jsonData) {
    return PillTaken(
        pillName: jsonData[PILL_NAME_KEY],
        pillWeight: jsonData[PILL_WEIGHT_KEY],
        description: jsonData[PILL_DESCRIPTION_KEY],
        lastTaken: jsonData[PILL_LAST_TAKEN_KEY] == null
            ? null
            : DateTime.parse(jsonData[PILL_LAST_TAKEN_KEY]));
  }

  static PillTaken extractFromPillToTake(PillToTake pillToTake) {
    return PillTaken(
        pillName: pillToTake.pillName,
        pillWeight: pillToTake.pillWeight,
        description: pillToTake.description,
        lastTaken: pillToTake.lastTaken);
  }

  static Map<String, dynamic> toMap(PillTaken pill) => {
        PILL_NAME_KEY: pill.pillName,
        PILL_WEIGHT_KEY: pill.pillWeight,
        PILL_DESCRIPTION_KEY: pill.description,
        PILL_LAST_TAKEN_KEY:
            pill.lastTaken == null ? null : pill.lastTaken!.toIso8601String()
      };

  static String encode(List<PillTaken> pills) => json.encode(
        pills
            .map<Map<String, dynamic>>((pill) => PillTaken.toMap(pill))
            .toList(),
      );

  static List<PillTaken> decode(String pills) =>
      (json.decode(pills) as List<dynamic>)
          .map<PillTaken>((pill) => PillTaken.fromJson(pill))
          .toList();
}

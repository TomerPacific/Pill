import 'dart:convert';

import 'package:pill/constants.dart';
import 'package:pill/model/pill_to_take.dart';

const String DEFAULT_PILL_IMAGE = 'assets/images/defaultPill.png';

class PillTaken {
  String pillName;
  String pillImage = DEFAULT_PILL_IMAGE;
  String? description;
  DateTime? lastTaken;

  PillTaken(
      {required this.pillName,
      this.description,
      required this.lastTaken});

  factory PillTaken.fromJson(Map<String, dynamic> jsonData) {
    String? lastTaken = jsonData[PILL_LAST_TAKEN_KEY];
    DateTime? lastTakenDate;
    try {
      if (lastTaken != null) {
        lastTakenDate = DateTime.parse(lastTaken);
      }
    } catch (e) {
      print("Error parsing PillTaken lastTaken value: $e");
    }

    return PillTaken(
        pillName: jsonData[PILL_NAME_KEY],
        description: jsonData[PILL_DESCRIPTION_KEY],
        lastTaken: lastTakenDate);
  }

  static PillTaken extractFromPillToTake(PillToTake pillToTake) {
    return PillTaken(
        pillName: pillToTake.pillName, lastTaken: pillToTake.lastTaken);
  }

  static Map<String, dynamic> toMap(PillTaken pill) => {
        PILL_NAME_KEY: pill.pillName,
    
        PILL_DESCRIPTION_KEY: pill.description,
        PILL_LAST_TAKEN_KEY: pill.lastTaken?.toIso8601String()
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

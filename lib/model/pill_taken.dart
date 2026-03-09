import 'dart:convert';
import 'dart:developer';

import 'package:pill/constants.dart';
import 'package:pill/model/pill_to_take.dart';

const String defaultPillTakenImage = 'assets/images/pill_taken.png';

class PillTaken {
  String pillName;
  String pillImage = defaultPillTakenImage;
  String? description;
  DateTime? lastTaken;

  PillTaken(
      {required this.pillName,
      this.description,
      required this.lastTaken});

  factory PillTaken.fromJson(Map<String, dynamic> jsonData) {
    String? lastTaken = jsonData[pillLastTakenKey];
    DateTime? lastTakenDate;
    try {
      if (lastTaken != null) {
        lastTakenDate = DateTime.parse(lastTaken);
      }
    } catch (e) {
      log("Error parsing PillTaken lastTaken value: $e", level: 1000);
    }

    return PillTaken(
        pillName: jsonData[pillNameKey],
        description: jsonData[pillDescriptionKey],
        lastTaken: lastTakenDate);
  }

  static PillTaken extractFromPillToTake(PillToTake pillToTake) {
    return PillTaken(
        pillName: pillToTake.pillName, lastTaken: pillToTake.lastTaken);
  }

  static Map<String, dynamic> toMap(PillTaken pill) => {
        pillNameKey: pill.pillName,
        pillDescriptionKey: pill.description,
        pillLastTakenKey: pill.lastTaken?.toIso8601String()
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

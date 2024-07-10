import 'dart:convert';
import 'package:pill/constants.dart';

class PillToTake {
  String pillName;
  double? pillWeight;
  int pillRegiment;
  String pillImage = 'assets/images/defaultPill.png';
  String? description;
  int amountOfDaysToTake;
  DateTime? lastTaken;

  PillToTake(
      {required this.pillName,
      this.pillWeight,
      required this.pillRegiment,
      this.description,
      required this.amountOfDaysToTake,
      this.lastTaken});

  factory PillToTake.fromJson(Map<String, dynamic> jsonData) {
    return PillToTake(
        pillName: jsonData[PILL_NAME_KEY],
        pillWeight: jsonData[PILL_WEIGHT_KEY],
        pillRegiment: jsonData[PILL_REGIMENT_KEY],
        description: jsonData[PILL_DESCRIPTION_KEY],
        amountOfDaysToTake: jsonData[PILL_AMOUNT_OF_DAYS_TO_TAKE_KEY],
        lastTaken: jsonData[PILL_LAST_TAKEN_KEY] == null
            ? null
            : DateTime.parse(jsonData[PILL_LAST_TAKEN_KEY]));
  }

  static Map<String, dynamic> toMap(PillToTake pill) => {
        PILL_NAME_KEY: pill.pillName,
        PILL_WEIGHT_KEY: pill.pillWeight,
        PILL_REGIMENT_KEY: pill.pillRegiment,
        PILL_DESCRIPTION_KEY: pill.description,
        PILL_AMOUNT_OF_DAYS_TO_TAKE_KEY: pill.amountOfDaysToTake,
        PILL_LAST_TAKEN_KEY:
            pill.lastTaken == null ? null : pill.lastTaken!.toIso8601String()
      };

  static String encode(List<PillToTake> pills) => json.encode(
        pills
            .map<Map<String, dynamic>>((pill) => PillToTake.toMap(pill))
            .toList(),
      );

  static List<PillToTake> decode(String pills) =>
      (json.decode(pills) as List<dynamic>)
          .map<PillToTake>((pill) => PillToTake.fromJson(pill))
          .toList();

  bool equals(PillToTake otherPill) {
    return (this.pillRegiment == otherPill.pillRegiment &&
        this.pillName == otherPill.pillName &&
        this.pillWeight == otherPill.pillWeight &&
        this.description == otherPill.description &&
        this.pillImage == otherPill.pillImage &&
        this.amountOfDaysToTake == otherPill.amountOfDaysToTake);
  }
}

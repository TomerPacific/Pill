import 'dart:convert';
import 'package:pill/constants.dart';

const String DEFAULT_PILL_TO_TAKE_IMAGE = 'assets/images/pill_to_take.png';


class PillToTake {
  String pillName;
  int pillRegiment;
  String pillImage = DEFAULT_PILL_TO_TAKE_IMAGE;
  String? description;
  int amountOfDaysToTake;
  DateTime? lastTaken;

  PillToTake(
      {required this.pillName,
      required this.pillRegiment,
      this.description,
      required this.amountOfDaysToTake,
      this.lastTaken});

  factory PillToTake.fromJson(Map<String, dynamic> jsonData) {

    String? lastTaken = jsonData[PILL_LAST_TAKEN_KEY];
    DateTime? lastTakenDate;

    try {
      if (lastTaken != null) {
        lastTakenDate = DateTime.parse(lastTaken);
      }
    } catch (e) {
      print("Error parsing PillToTake lastTaken value: $e");
    }

    return PillToTake(
        pillName: jsonData[PILL_NAME_KEY],
        pillRegiment: jsonData[PILL_REGIMENT_KEY],
        description: jsonData[PILL_DESCRIPTION_KEY],
        amountOfDaysToTake: jsonData[PILL_AMOUNT_OF_DAYS_TO_TAKE_KEY],
        lastTaken: lastTakenDate);
  }

  static Map<String, dynamic> toMap(PillToTake pill) => {
        PILL_NAME_KEY: pill.pillName,
        PILL_REGIMENT_KEY: pill.pillRegiment,
        PILL_DESCRIPTION_KEY: pill.description,
        PILL_AMOUNT_OF_DAYS_TO_TAKE_KEY: pill.amountOfDaysToTake,
        PILL_LAST_TAKEN_KEY: pill.lastTaken?.toIso8601String()
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
        this.description == otherPill.description &&
        this.pillImage == otherPill.pillImage &&
        this.amountOfDaysToTake == otherPill.amountOfDaysToTake);
  }

  PillToTake copyWith({
    String? pillName,
    int? pillRegiment,
    String? description,
    int? amountOfDaysToTake,
    DateTime? lastTaken,
  }) {
    return PillToTake(
      pillName: pillName ?? this.pillName,
      pillRegiment: pillRegiment ?? this.pillRegiment,
      description: description ?? this.description,
      amountOfDaysToTake: amountOfDaysToTake ?? this.amountOfDaysToTake,
      lastTaken: lastTaken ?? this.lastTaken,
    );
  }
}

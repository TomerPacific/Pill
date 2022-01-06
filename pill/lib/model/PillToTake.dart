import 'dart:convert';
import 'package:pill/constants.dart';

class PillToTake {
  String pillName;
  double pillWeight;
  String pillRegiment;
  String pillImage = 'assets/images/defaultPill.png';
  String description;

  PillToTake({
    this.pillName = "Random Pill",
    this.pillWeight = 0,
    this.pillRegiment = "1",
    this.description = "Description"
  });

  factory PillToTake.fromJson(Map<String, dynamic> jsonData) {
    return PillToTake(
      pillName: jsonData[PILL_NAME_KEY],
      pillWeight: jsonData[PILL_WEIGHT_KEY],
      pillRegiment: jsonData[PILL_REGIMENT_KEY],
      description: jsonData[PILL_DESCRIPTION_KEY]
    );
  }

  static Map<String, dynamic> toMap(PillToTake pill) => {
    PILL_NAME_KEY: pill.pillName,
    PILL_WEIGHT_KEY: pill.pillWeight,
    PILL_REGIMENT_KEY: pill.pillRegiment,
    PILL_DESCRIPTION_KEY: pill.description
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
    return (
        this.pillRegiment == otherPill.pillRegiment &&
        this.pillName == otherPill.pillName &&
        this.pillWeight == otherPill.pillWeight &&
        this.description == otherPill.description &&
        this.pillImage == otherPill.pillImage);
  }
}
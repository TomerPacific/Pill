import 'dart:convert';
import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:pill/constants.dart';

const String defaultPillToTakeImage = 'assets/images/pill_to_take.png';

class PillToTake extends Equatable {
  final String pillName;
  final int pillRegiment;
  final String pillImage;
  final String? description;
  final int amountOfDaysToTake;
  final DateTime? lastTaken;

  const PillToTake(
      {required this.pillName,
      required this.pillRegiment,
      this.pillImage = defaultPillToTakeImage,
      this.description,
      required this.amountOfDaysToTake,
      this.lastTaken});

  factory PillToTake.fromJson(Map<String, dynamic> jsonData) {
    final lastTakenValue = jsonData[pillLastTakenKey];
    final String? lastTaken = lastTakenValue is String ? lastTakenValue : null;

    DateTime? lastTakenDate;

    try {
      if (lastTaken != null) {
        lastTakenDate = DateTime.parse(lastTaken);
      }
    } catch (e) {
      log("Error parsing PillToTake lastTaken value: $e", level: 1000);
    }

    final nameValue = jsonData[pillNameKey];
    final regimentValue = jsonData[pillRegimentKey];
    final imageValue = jsonData[pillImageKey];
    final descValue = jsonData[pillDescriptionKey];
    final daysValue = jsonData[pillAmountOfDaysToTakeKey];

    return PillToTake(
        pillName: nameValue is String ? nameValue : 'Unknown',
        pillRegiment: regimentValue is int ? regimentValue : 1,
        pillImage: imageValue is String ? imageValue : defaultPillToTakeImage,
        description: descValue is String ? descValue : null,
        amountOfDaysToTake: daysValue is int ? daysValue : 1,
        lastTaken: lastTakenDate);
  }

  static Map<String, dynamic> toMap(PillToTake pill) => {
        pillNameKey: pill.pillName,
        pillRegimentKey: pill.pillRegiment,
        pillImageKey: pill.pillImage,
        pillDescriptionKey: pill.description,
        pillAmountOfDaysToTakeKey: pill.amountOfDaysToTake,
        pillLastTakenKey: pill.lastTaken?.toIso8601String()
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

  PillToTake copyWith({
    String? pillName,
    int? pillRegiment,
    String? pillImage,
    String? description,
    bool clearDescription = false,
    int? amountOfDaysToTake,
    DateTime? lastTaken,
    bool clearLastTaken = false,
  }) {
    return PillToTake(
      pillName: pillName ?? this.pillName,
      pillRegiment: pillRegiment ?? this.pillRegiment,
      pillImage: pillImage ?? this.pillImage,
      description: clearDescription ? null : (description ?? this.description),
      amountOfDaysToTake: amountOfDaysToTake ?? this.amountOfDaysToTake,
      lastTaken: clearLastTaken ? null : (lastTaken ?? this.lastTaken),
    );
  }

  @override
  List<Object?> get props => [
        pillName,
        pillRegiment,
        pillImage,
        description,
        amountOfDaysToTake,
        lastTaken
      ];
}

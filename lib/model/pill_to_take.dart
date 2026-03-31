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
    String? lastTaken = jsonData[pillLastTakenKey];
    DateTime? lastTakenDate;

    try {
      if (lastTaken != null) {
        lastTakenDate = DateTime.parse(lastTaken);
      }
    } catch (e) {
      log("Error parsing PillToTake lastTaken value: $e", level: 1000);
    }

    return PillToTake(
        pillName: jsonData[pillNameKey],
        pillRegiment: jsonData[pillRegimentKey],
        pillImage: jsonData[pillImageKey] ?? defaultPillToTakeImage,
        description: jsonData[pillDescriptionKey],
        amountOfDaysToTake: jsonData[pillAmountOfDaysToTakeKey],
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
    Object? description = _sentinel,
    int? amountOfDaysToTake,
    Object? lastTaken = _sentinel,
  }) {
    return PillToTake(
      pillName: pillName ?? this.pillName,
      pillRegiment: pillRegiment ?? this.pillRegiment,
      pillImage: pillImage ?? this.pillImage,
      description: description == _sentinel ? this.description : description as String?,
      amountOfDaysToTake: amountOfDaysToTake ?? this.amountOfDaysToTake,
      lastTaken: lastTaken == _sentinel ? this.lastTaken : lastTaken as DateTime?,
    );
  }

  static const _sentinel = Object();

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

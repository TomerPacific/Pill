import 'dart:convert';
import 'dart:developer';
import 'package:equatable/equatable.dart';

import 'package:pill/constants.dart';
import 'package:pill/model/pill_to_take.dart';

const String defaultPillTakenImage = 'assets/images/pill_taken.png';

class PillTaken extends Equatable {
  final String pillName;
  final String pillImage;
  final String? description;
  final DateTime? lastTaken;

  const PillTaken(
      {required this.pillName,
      this.pillImage = defaultPillTakenImage,
      this.description,
      required this.lastTaken});

  factory PillTaken.fromJson(Map<String, dynamic> jsonData) {
    String? lastTaken = jsonData[pillLastTakenKey] as String?;
    DateTime? lastTakenDate;
    try {
      if (lastTaken != null) {
        lastTakenDate = DateTime.parse(lastTaken);
      }
    } catch (e) {
      log("Error parsing PillTaken lastTaken value: $e", level: 1000);
    }

    return PillTaken(
        pillName: jsonData[pillNameKey] as String? ?? 'Unknown',
        pillImage: jsonData[pillImageKey] as String? ?? defaultPillTakenImage,
        description: jsonData[pillDescriptionKey] as String?,
        lastTaken: lastTakenDate);
  }

  static PillTaken extractFromPillToTake(PillToTake pillToTake) {
    return PillTaken(
        pillName: pillToTake.pillName,
        pillImage: pillToTake.pillImage == defaultPillToTakeImage
            ? defaultPillTakenImage
            : pillToTake.pillImage,
        description: pillToTake.description,
        lastTaken: pillToTake.lastTaken);
  }

  static Map<String, dynamic> toMap(PillTaken pill) => {
        pillNameKey: pill.pillName,
        pillImageKey: pill.pillImage,
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

  PillTaken copyWith({
    String? pillName,
    String? pillImage,
    String? description,
    DateTime? lastTaken,
    bool clearDescription = false,
    bool clearLastTaken = false,
  }) {
    return PillTaken(
      pillName: pillName ?? this.pillName,
      pillImage: pillImage ?? this.pillImage,
      description: clearDescription ? null : (description ?? this.description),
      lastTaken: clearLastTaken ? null : (lastTaken ?? this.lastTaken),
    );
  }

  @override
  List<Object?> get props => [pillName, pillImage, description, lastTaken];
}

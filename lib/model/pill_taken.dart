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
    DateTime? lastTakenDate;
    try {
      final lastTakenValue = jsonData[pillLastTakenKey];
      if (lastTakenValue is String) {
        lastTakenDate = DateTime.parse(lastTakenValue);
      }
    } catch (e) {
      log("Error parsing PillTaken lastTaken value: $e", level: 1000);
    }

    final nameValue = jsonData[pillNameKey];
    final String name = nameValue is String ? nameValue : 'Unknown';

    final imageValue = jsonData[pillImageKey];
    final String image = imageValue is String ? imageValue : defaultPillTakenImage;

    final descriptionValue = jsonData[pillDescriptionKey];
    final String? description = descriptionValue is String ? descriptionValue : null;

    return PillTaken(
        pillName: name,
        pillImage: image,
        description: description,
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

  static List<PillTaken> decode(String pills) {
    if (pills.isEmpty) return [];
    try {
      final decoded = json.decode(pills);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map<PillTaken>((pill) => PillTaken.fromJson(pill))
            .toList();
      } else {
        log("PillTaken.decode: decoded JSON is not a list. Actual type: ${decoded.runtimeType}", level: 1000);
      }
    } catch (e) {
      log("Error decoding PillTaken list: $e", level: 1000);
    }
    return [];
  }

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

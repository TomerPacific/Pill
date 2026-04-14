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
    DateTime? lastTakenDate;
    try {
      final lastTakenValue = jsonData[pillLastTakenKey];
      if (lastTakenValue is String) {
        lastTakenDate = DateTime.parse(lastTakenValue);
      }
    } catch (e) {
      log("Error parsing PillToTake lastTaken value: $e", level: 1000);
    }

    final nameValue = jsonData[pillNameKey];
    final String name = nameValue is String ? nameValue : 'Unknown';
    
    final regimentValue = jsonData[pillRegimentKey];
    final int regiment = regimentValue is num 
        ? regimentValue.toInt() 
        : num.tryParse(regimentValue?.toString() ?? '')?.toInt() ?? 1;

    final imageValue = jsonData[pillImageKey];
    final String image = imageValue is String ? imageValue : defaultPillToTakeImage;
    
    final descriptionValue = jsonData[pillDescriptionKey];
    final String? description = descriptionValue is String ? descriptionValue : null;

    final daysValue = jsonData[pillAmountOfDaysToTakeKey];
    final int amountOfDays = daysValue is num 
        ? daysValue.toInt() 
        : num.tryParse(daysValue?.toString() ?? '')?.toInt() ?? 1;

    return PillToTake(
        pillName: name,
        pillRegiment: regiment,
        pillImage: image,
        description: description,
        amountOfDaysToTake: amountOfDays,
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

  static List<PillToTake> decode(String pills) {
    if (pills.isEmpty) return [];
    try {
      final decoded = json.decode(pills);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map<PillToTake>((pill) => PillToTake.fromJson(pill))
            .toList();
      } else {
        log("PillToTake.decode: decoded JSON is not a list. Actual type: ${decoded.runtimeType}", level: 1000);
      }
    } catch (e) {
      log("Error decoding PillToTake list: $e", level: 1000);
    }
    return [];
  }

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

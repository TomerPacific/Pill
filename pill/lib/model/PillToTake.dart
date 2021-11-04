import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pill/model/PillRegiment.dart';

class PillToTake {
  String pillName;
  double pillWeight;
  PillRegiment pillRegiment;
  String description;

  PillToTake({
    this.pillName,
    this.pillWeight,
    this.pillRegiment,
    this.description
  });

  factory PillToTake.fromJson(Map<String, dynamic> jsonData) {
    return PillToTake(
      pillName: jsonData['pillName'],
      pillWeight: jsonData['pillWeight'],
      pillRegiment: PillRegimentHelper.getPillRegiment(jsonData['pillRegiment']),
      description: jsonData['description']
    );
  }

  static Map<String, dynamic> toMap(PillToTake pill) => {
    'pillName': pill.pillName,
    'pillWeight': pill.pillWeight,
    'pillRegiment': describeEnum(pill.pillRegiment),
    'description': pill.description
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
}
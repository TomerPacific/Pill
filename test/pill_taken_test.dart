import 'package:flutter_test/flutter_test.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/constants.dart';

void main() {
  group('PillTaken.extractFromPillToTake', () {
    test('should use defaultPillTakenImage when PillToTake has defaultPillToTakeImage', () {
      const pillToTake = PillToTake(
        id: '1',
        pillName: 'Test Pill',
        pillRegiment: 1,
        amountOfDaysToTake: 1,
        pillImage: defaultPillToTakeImage,
      );

      final pillTaken = PillTaken.extractFromPillToTake(pillToTake);

      expect(pillTaken.pillImage, defaultPillTakenImage);
    });

    test('should preserve custom image from PillToTake', () {
      const customImage = 'assets/images/custom_pill.png';
      const pillToTake = PillToTake(
        id: '1',
        pillName: 'Test Pill',
        pillRegiment: 1,
        amountOfDaysToTake: 1,
        pillImage: customImage,
      );

      final pillTaken = PillTaken.extractFromPillToTake(pillToTake);

      expect(pillTaken.pillImage, customImage);
    });
  });

  group('PillTaken.decode', () {
    test('should return empty list for invalid JSON string', () {
      const invalidJson = 'invalid json';
      final result = PillTaken.decode(invalidJson);
      expect(result, isEmpty);
    });

    test('should return empty list for non-list JSON', () {
      const mapJson = '{"key": "value"}';
      final result = PillTaken.decode(mapJson);
      expect(result, isEmpty);
    });

    test('should return list of PillTaken for valid JSON list', () {
      const validJson = '[{"pillName": "Advil", "lastTaken": "2023-10-27T10:00:00Z"}]';
      final result = PillTaken.decode(validJson);
      expect(result.length, 1);
      expect(result[0].pillName, 'Advil');
    });

    test('should skip non-map elements in JSON list', () {
      const mixedJson = '[{"pillName": "Advil"}, "not a map", 123]';
      final result = PillTaken.decode(mixedJson);
      expect(result.length, 1);
      expect(result[0].pillName, 'Advil');
    });
  });

  group('PillTaken.fromJson', () {
    test('should handle missing fields with defaults', () {
      final json = <String, dynamic>{};
      final pillTaken = PillTaken.fromJson(json);

      expect(pillTaken.pillName, 'Unknown');
      expect(pillTaken.pillImage, defaultPillTakenImage);
      expect(pillTaken.description, isNull);
      expect(pillTaken.lastTaken, isNull);
    });

    test('should handle wrong-typed fields with defaults', () {
      final json = <String, dynamic>{
        pillNameKey: 123,
        pillImageKey: true,
        pillDescriptionKey: 456,
        pillLastTakenKey: 'not-a-date'
      };
      final pillTaken = PillTaken.fromJson(json);

      expect(pillTaken.pillName, 'Unknown');
      expect(pillTaken.pillImage, defaultPillTakenImage);
      expect(pillTaken.description, isNull);
      expect(pillTaken.lastTaken, isNull);
    });

    test('should parse valid lastTaken date', () {
      const dateString = '2023-10-27T10:00:00.000Z';
      final json = <String, dynamic>{
        pillLastTakenKey: dateString
      };
      final pillTaken = PillTaken.fromJson(json);

      expect(pillTaken.lastTaken, DateTime.parse(dateString));
    });
  });
}

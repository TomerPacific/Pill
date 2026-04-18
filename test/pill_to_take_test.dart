import 'package:flutter_test/flutter_test.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/constants.dart';

void main() {
  group('PillToTake copyWith', () {
    const pill = PillToTake(
      id: 'test_id',
      pillName: 'Test',
      pillRegiment: 1,
      amountOfDaysToTake: 1,
      description: 'Original Description',
    );

    test('should update fields correctly', () {
      final updated = pill.copyWith(pillName: 'Updated');
      expect(updated.pillName, 'Updated');
      expect(updated.id, 'test_id');
      expect(updated.description, 'Original Description');
    });

    test('should clear description using clearDescription flag', () {
      final updated = pill.copyWith(clearDescription: true);
      expect(updated.description, isNull);
    });

    test('should set lastTaken correctly', () {
      final now = DateTime.now();
      final updated = pill.copyWith(lastTaken: now);
      expect(updated.lastTaken, now);
    });

    test('should clear lastTaken using clearLastTaken flag', () {
      final now = DateTime.now();
      final pillWithDate = pill.copyWith(lastTaken: now);
      final updated = pillWithDate.copyWith(clearLastTaken: true);
      expect(updated.lastTaken, isNull);
    });
  });

  group('PillToTake.fromJson', () {
    test('should parse numeric values from double', () {
      final json = {
        pillIdKey: 'test_id',
        pillNameKey: 'Test Pill',
        pillRegimentKey: 2.0,
        pillAmountOfDaysToTakeKey: 7.0,
      };

      final pill = PillToTake.fromJson(json);

      expect(pill.id, 'test_id');
      expect(pill.pillRegiment, 2);
      expect(pill.amountOfDaysToTake, 7);
    });

    test('should parse numeric values from string double', () {
      final json = {
        pillIdKey: 'test_id',
        pillNameKey: 'Test Pill',
        pillRegimentKey: '2.0',
        pillAmountOfDaysToTakeKey: '7.0',
      };

      final pill = PillToTake.fromJson(json);

      expect(pill.id, 'test_id');
      expect(pill.pillRegiment, 2);
      expect(pill.amountOfDaysToTake, 7);
    });

    test('should fallback to 1 for invalid values', () {
      final json = {
        pillNameKey: 'Test Pill',
        pillRegimentKey: 'abc',
        pillAmountOfDaysToTakeKey: null,
      };

      final pill = PillToTake.fromJson(json);

      expect(pill.pillRegiment, 1);
      expect(pill.amountOfDaysToTake, 1);
    });

    test('should handle missing fields with defaults', () {
      final json = <String, dynamic>{};
      final pill = PillToTake.fromJson(json);

      expect(pill.pillName, 'Unknown');
      expect(pill.pillRegiment, 1);
      expect(pill.pillImage, defaultPillToTakeImage);
      expect(pill.description, isNull);
      expect(pill.amountOfDaysToTake, 1);
      expect(pill.lastTaken, isNull);
      expect(pill.id, startsWith('Unknown_'));
    });

    test('should handle wrong-typed fields with defaults', () {
      final json = <String, dynamic>{
        pillNameKey: 123,
        pillRegimentKey: true,
        pillImageKey: 456,
        pillDescriptionKey: 789,
        pillAmountOfDaysToTakeKey: 'not-a-number-or-double',
        pillLastTakenKey: 101112,
      };
      final pill = PillToTake.fromJson(json);

      expect(pill.pillName, 'Unknown');
      expect(pill.pillRegiment, 1);
      expect(pill.pillImage, defaultPillToTakeImage);
      expect(pill.description, isNull);
      expect(pill.amountOfDaysToTake, 1);
      expect(pill.lastTaken, isNull);
      expect(pill.id, startsWith('Unknown_'));
    });

    test('should parse valid lastTaken date', () {
      const dateString = '2023-10-27T10:00:00.000Z';
      final json = <String, dynamic>{
        pillIdKey: 'test_id',
        pillLastTakenKey: dateString
      };
      final pill = PillToTake.fromJson(json);

      expect(pill.id, 'test_id');
      expect(pill.lastTaken, DateTime.parse(dateString));
    });
  });

  group('PillToTake.decode', () {
    test('should return empty list for invalid JSON string', () {
      const invalidJson = 'invalid json';
      final result = PillToTake.decode(invalidJson);
      expect(result, isEmpty);
    });

    test('should return empty list for non-list JSON', () {
      const mapJson = '{"key": "value"}';
      final result = PillToTake.decode(mapJson);
      expect(result, isEmpty);
    });

    test('should return list of PillToTake for valid JSON list', () {
      const validJson = '[{"id": "id1", "pillName": "Advil", "pillRegiment": 2, "amountOfDaysToTake": 7}]';
      final result = PillToTake.decode(validJson);
      expect(result.length, 1);
      expect(result[0].id, 'id1');
      expect(result[0].pillName, 'Advil');
      expect(result[0].pillRegiment, 2);
    });

    test('should skip non-map elements in JSON list', () {
      const mixedJson = '[{"pillName": "Advil"}, "not a map", 123]';
      final result = PillToTake.decode(mixedJson);
      expect(result.length, 1);
      expect(result[0].pillName, 'Advil');
    });
  });
}

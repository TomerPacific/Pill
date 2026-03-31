import 'package:flutter_test/flutter_test.dart';
import 'package:pill/model/pill_to_take.dart';

void main() {
  group('PillToTake copyWith', () {
    const pill = PillToTake(
      pillName: 'Test',
      pillRegiment: 1,
      amountOfDaysToTake: 1,
      description: 'Original Description',
    );

    test('should update fields correctly', () {
      final updated = pill.copyWith(pillName: 'Updated');
      expect(updated.pillName, 'Updated');
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
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/model/pill_to_take.dart';

void main() {
  group('PillTaken.extractFromPillToTake', () {
    test('should use defaultPillTakenImage when PillToTake has defaultPillToTakeImage', () {
      const pillToTake = PillToTake(
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
        pillName: 'Test Pill',
        pillRegiment: 1,
        amountOfDaysToTake: 1,
        pillImage: customImage,
      );

      final pillTaken = PillTaken.extractFromPillToTake(pillToTake);

      expect(pillTaken.pillImage, customImage);
    });
  });
}

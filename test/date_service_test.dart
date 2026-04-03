import 'package:flutter_test/flutter_test.dart';
import 'package:pill/service/date_service.dart';

void main() {
  DateService dateService = DateService();

  test("DateService formatDateForStorage returns YYYY/M/D", () {
    final DateTime date = DateTime.parse("2022-05-06");
    final String str = dateService.formatDateForStorage(date);
    expect(str, equals("2022/5/6"));
  });

  test("DateService formatDateForDisplay returns M/D", () {
    final DateTime date = DateTime.parse("2022-05-06");
    final String str = dateService.formatDateForDisplay(date);
    expect(str, equals("5/6"));
  });

  test("DateService get hour from date", () {
    final DateTime date = DateTime.parse("2022-05-06 18:42:35");
    final String str = dateService.getHourFromDate(date);
    expect(str, equals("18:42:35"));
  });
}

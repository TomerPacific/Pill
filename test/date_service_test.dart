import 'package:flutter_test/flutter_test.dart';
import 'package:pill/service/date_service.dart';

void main() {
  DateService dateService = DateService();

  test("DateService convert date to month and day", () {
    final DateTime date = DateTime.parse("2022-05-06");
    final String str = dateService.getDateAsMonthAndDay(date);
    expect(str, equals("5/6"));
  });

  test("DateService get hour from date", () {
    final DateTime date = DateTime.parse("2022-05-06 18:42:35");
    final String str = dateService.getHourFromDate(date);
    expect(str, equals("18:42:35"));
  });
}

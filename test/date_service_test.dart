
import 'package:flutter_test/flutter_test.dart';
import 'package:pill/service/DateService.dart';

void main() {

  test("DateService convert date to month and day", () {
    final DateTime date = DateTime.parse("2022-05-06");
    final String str = DateService().getDateAsMonthAndDay(date);
    expect(str, equals("5/6"));
  });

  test("DateService get hour from date", () {
    final DateTime date = DateTime.parse("2022-05-06 18:42:35");
    final String str = DateService().getHourFromDate(date);
    expect(str, equals("18:42:35"));
  });

}
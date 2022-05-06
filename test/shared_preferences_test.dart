import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {

  late String date;

  setUp(() async {
    await SharedPreferencesService().init();
    SharedPreferences.setMockInitialValues({});
    date = "5/6";
  });

  test("SharedPreferences Service get pills for date empty", () {
      List<PillToTake> pills = SharedPreferencesService().getPillsToTakeForDate(date);
      expect(pills.length, 0);
  });


  test("SharedPreferences Service add pill to date", () {
    PillToTake pill = new PillToTake(pillName: "Test Pill", pillRegiment: 2, amountOfDaysToTake: 1);
    SharedPreferencesService().addPillToDates(date, pill);
    List<PillToTake> pills = SharedPreferencesService().getPillsToTakeForDate(date);

    expect(pills.length, 1);

    List<PillToTake> found = pills.where((element) => element.pillName == pill.pillName).toList();

    expect(found.length, 1);
  });


}
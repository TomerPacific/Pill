import 'package:flutter_test/flutter_test.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  DateService dateService = new DateService();
  SharedPreferences.setMockInitialValues({});
  SharedPreferencesService sharedPreferencesService =
      await SharedPreferencesService.create(dateService);
  final String date = DateService().getCurrentDateAsMonthAndDay();

  setUp(() {
    sharedPreferencesService.clearAllPills();
  });

  test("SharedPreferences Service get pills for date (where no pills exist)",
      () {
    List<PillToTake> pills =
        sharedPreferencesService.getPillsToTakeForDate(date);
    expect(pills.length, 0);
  });

  test("SharedPreferences Service add pill to date", () {
    PillToTake pill = new PillToTake(
        pillName: "Test Pill", pillRegiment: 2, amountOfDaysToTake: 1);
    sharedPreferencesService.addPillToDates(date, pill);
    List<PillToTake> pills =
        sharedPreferencesService.getPillsToTakeForDate(date);

    expect(pills.length, 1);

    List<PillToTake> found =
        pills.where((element) => element.pillName == pill.pillName).toList();

    expect(found.length, 1);
  });

  test("SharedPreferences Service remove pill from date", () {
    PillToTake pill = new PillToTake(
        pillName: "Test Pill", pillRegiment: 2, amountOfDaysToTake: 1);
    sharedPreferencesService.addPillToDates(date, pill);
    List<PillToTake> pills =
        sharedPreferencesService.getPillsToTakeForDate(date);

    expect(pills.length, 1);

    sharedPreferencesService.removePillFromDate(pill, date);

    pills = sharedPreferencesService.getPillsToTakeForDate(date);

    expect(pills.length, 0);
  });

  test("SharedPreferences Service update pill from date", () {
    PillToTake pill = new PillToTake(
        pillName: "Test Pill", pillRegiment: 2, amountOfDaysToTake: 1);
    sharedPreferencesService.addPillToDates(date, pill);
    List<PillToTake> pills =
        sharedPreferencesService.getPillsToTakeForDate(date);

    expect(pills.length, 1);

    pill.pillRegiment = 10;

    sharedPreferencesService.updatePillForDate(pill, date);

    pills = sharedPreferencesService.getPillsToTakeForDate(date);

    PillToTake updatedPill = pills[0];

    expect(updatedPill.pillRegiment, 10);
  });

  test("SharedPreferences Service Clearing All Pills", () {
    PillToTake pill = new PillToTake(
        pillName: "Test Pill", pillRegiment: 2, amountOfDaysToTake: 1);
    sharedPreferencesService.addPillToDates(date, pill);
    List<PillToTake> pills =
        sharedPreferencesService.getPillsToTakeForDate(date);

    expect(pills.length, 1);

    bool areTherePillsToTake =
        sharedPreferencesService.areThereAnyPillsToTake();

    expect(areTherePillsToTake, true);

    sharedPreferencesService.clearAllPills();

    areTherePillsToTake = sharedPreferencesService.areThereAnyPillsToTake();

    expect(areTherePillsToTake, false);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {

  final String date = DateService().getCurrentDateAsMonthAndDay();

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesService().init();
    SharedPreferencesService().clearAllPills();
  });

  test("SharedPreferences Service get pills for date (where no pills exist)", () {
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

  test("SharedPreferences Service remove pill from date", () {
    PillToTake pill = new PillToTake(pillName: "Test Pill", pillRegiment: 2, amountOfDaysToTake: 1);
    SharedPreferencesService().addPillToDates(date, pill);
    List<PillToTake> pills = SharedPreferencesService().getPillsToTakeForDate(date);

    expect(pills.length, 1);

    SharedPreferencesService().removePillFromDate(pill, date);

    pills = SharedPreferencesService().getPillsToTakeForDate(date);

    expect(pills.length, 0);
  });

  test("SharedPreferences Service update pill from date", () {
    PillToTake pill = new PillToTake(pillName: "Test Pill", pillRegiment: 2, amountOfDaysToTake: 1);
    SharedPreferencesService().addPillToDates(date, pill);
    List<PillToTake> pills = SharedPreferencesService().getPillsToTakeForDate(date);

    expect(pills.length, 1);

    pill.pillRegiment = 10;

    SharedPreferencesService().updatePillForDate(pill, date);

    pills = SharedPreferencesService().getPillsToTakeForDate(date);

    PillToTake updatedPill = pills[0];

    expect(updatedPill.pillRegiment, 10);
  });

  test("SharedPreferences Service Clearing All Pills", () {
    PillToTake pill = new PillToTake(pillName: "Test Pill", pillRegiment: 2, amountOfDaysToTake: 1);
    SharedPreferencesService().addPillToDates(date, pill);
    List<PillToTake> pills = SharedPreferencesService().getPillsToTakeForDate(date);

    expect(pills.length, 1);

    bool areTherePillsToTake = SharedPreferencesService().areThereAnyPillsToTake();

    expect(areTherePillsToTake, true);

    SharedPreferencesService().clearAllPills();

    areTherePillsToTake = SharedPreferencesService().areThereAnyPillsToTake();

    expect(areTherePillsToTake, false);

  });

}
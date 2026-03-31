import 'package:flutter_test/flutter_test.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  DateService dateService = DateService();
  SharedPreferences.setMockInitialValues({});
  SharedPreferencesService sharedPreferencesService =
      await SharedPreferencesService.create(dateService);
  final DateTime now = DateTime.now();
  final String date = DateService().getDateAsMonthAndDay(now);

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
    const PillToTake pill = PillToTake(
        pillName: "Test Pill", pillRegiment: 2, amountOfDaysToTake: 1);
    sharedPreferencesService.addPillToDates(now, pill);
    List<PillToTake> pills =
        sharedPreferencesService.getPillsToTakeForDate(date);

    expect(pills.length, 1);

    List<PillToTake> found =
        pills.where((element) => element.pillName == pill.pillName).toList();

    expect(found.length, 1);
  });

  test("SharedPreferences Service remove pill from date", () {
    const PillToTake pill = PillToTake(
        pillName: "Test Pill", pillRegiment: 2, amountOfDaysToTake: 1);
    sharedPreferencesService.addPillToDates(now, pill);
    List<PillToTake> pills =
        sharedPreferencesService.getPillsToTakeForDate(date);

    expect(pills.length, 1);

    sharedPreferencesService.removePillFromDate(pill, date);

    pills = sharedPreferencesService.getPillsToTakeForDate(date);

    expect(pills.length, 0);
  });

  test("SharedPreferences Service update pill from date", () {
    const PillToTake pill = PillToTake(
        pillName: "Test Pill", pillRegiment: 2, amountOfDaysToTake: 1);
    sharedPreferencesService.addPillToDates(now, pill);
    List<PillToTake> pills =
        sharedPreferencesService.getPillsToTakeForDate(date);

    expect(pills.length, 1);

    PillToTake updatedPillInstance = pill.copyWith(pillRegiment: 10);

    sharedPreferencesService.updatePillForDate(updatedPillInstance, date);

    pills = sharedPreferencesService.getPillsToTakeForDate(date);

    PillToTake updatedPill = pills[0];

    expect(updatedPill.pillRegiment, 10);
  });

  test("SharedPreferences Service update pill from date - pill not found guard", () {
    const PillToTake pill = PillToTake(
        pillName: "Non Existent Pill", pillRegiment: 2, amountOfDaysToTake: 1);
    
    // This should not throw RangeError
    sharedPreferencesService.updatePillForDate(pill, date);
    
    List<PillToTake> pills = sharedPreferencesService.getPillsToTakeForDate(date);
    expect(pills.length, 0);
    
    List<PillTaken> pillsTaken = sharedPreferencesService.getPillsTakenForDate(date);
    // Verification: No entry should be added for a pill not in the schedule
    expect(pillsTaken.length, 0);
  });

  test("SharedPreferences Service pillImage persistence", () {
    const String customImage = "assets/images/custom_pill.png";
    const PillToTake pill = PillToTake(
        pillName: "Custom Image Pill", 
        pillRegiment: 2, 
        amountOfDaysToTake: 1,
        pillImage: customImage);
    
    sharedPreferencesService.addPillToDates(now, pill);
    
    List<PillToTake> pills = sharedPreferencesService.getPillsToTakeForDate(date);
    expect(pills[0].pillImage, customImage);
    
    sharedPreferencesService.updatePillForDate(pill, date);
    List<PillTaken> pillsTaken = sharedPreferencesService.getPillsTakenForDate(date);
    expect(pillsTaken[0].pillImage, customImage);
  });

  test("SharedPreferences Service Clearing All Pills", () {
    const PillToTake pill = PillToTake(
        pillName: "Test Pill", pillRegiment: 2, amountOfDaysToTake: 1);
    sharedPreferencesService.addPillToDates(now, pill);
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

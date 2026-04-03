import 'package:flutter_test/flutter_test.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:pill/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final DateService dateService = DateService();
  late SharedPreferencesService sharedPreferencesService;
  final DateTime now = DateTime.now();
  final String date = dateService.getDateAsYearMonthDay(now);

  setUp(() async {
    // Reset SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
    sharedPreferencesService =
        await SharedPreferencesService.create(dateService);
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

  test(
      "SharedPreferences Service remove pill from date (case-insensitive and trimmed)",
      () {
    const PillToTake pill = PillToTake(
        pillName: "Test Pill", pillRegiment: 2, amountOfDaysToTake: 1);
    sharedPreferencesService.addPillToDates(now, pill);

    // Attempt removal with different casing and whitespace
    const PillToTake pillToRemove = PillToTake(
        pillName: "  test pill  ", pillRegiment: 2, amountOfDaysToTake: 1);

    sharedPreferencesService.removePillFromDate(pillToRemove, date);

    List<PillToTake> pills =
        sharedPreferencesService.getPillsToTakeForDate(date);
    expect(pills.length, 0);
  });

  test("SharedPreferences Service update pill from date", () {
    const PillToTake pill = PillToTake(
        pillName: "Test Pill", pillRegiment: 2, amountOfDaysToTake: 1);
    sharedPreferencesService.addPillToDates(now, pill);
    List<PillToTake> pills =
        sharedPreferencesService.getPillsToTakeForDate(date);

    expect(pills.length, 1);

    final PillToTake updatedPillInstance = pill.copyWith(pillRegiment: 10);

    sharedPreferencesService.updatePillForDate(updatedPillInstance, date);

    pills = sharedPreferencesService.getPillsToTakeForDate(date);

    PillToTake updatedPill = pills[0];

    expect(updatedPill.pillRegiment, 10);
  });

  test(
      "SharedPreferences Service update pill from date (case-insensitive and trimmed)",
      () {
    const PillToTake pill = PillToTake(
        pillName: "Test Pill", pillRegiment: 2, amountOfDaysToTake: 1);
    sharedPreferencesService.addPillToDates(now, pill);

    // Update with different casing and whitespace
    const PillToTake updatedPillInstance = PillToTake(
        pillName: "  test pill  ", pillRegiment: 10, amountOfDaysToTake: 1);

    sharedPreferencesService.updatePillForDate(updatedPillInstance, date);

    List<PillToTake> pills =
        sharedPreferencesService.getPillsToTakeForDate(date);
    expect(pills.length, 1);
    expect(pills[0].pillRegiment, 10);
  });

  test(
      "SharedPreferences Service update pill from date - pill not found guard",
      () {
    const PillToTake pill = PillToTake(
        pillName: "Non Existent Pill", pillRegiment: 2, amountOfDaysToTake: 1);

    // This should not throw RangeError
    sharedPreferencesService.updatePillForDate(pill, date);

    List<PillToTake> pills =
        sharedPreferencesService.getPillsToTakeForDate(date);
    expect(pills.length, 0);

    List<PillTaken> pillsTaken =
        sharedPreferencesService.getPillsTakenForDate(date);
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

    List<PillToTake> pills =
        sharedPreferencesService.getPillsToTakeForDate(date);
    expect(pills[0].pillImage, customImage);

    sharedPreferencesService.updatePillForDate(pill, date);
    List<PillTaken> pillsTaken =
        sharedPreferencesService.getPillsTakenForDate(date);
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

  group("SharedPreferences Service migration", () {
    test("Standard migration", () async {
      const pill = PillToTake(
          pillName: "Test Pill", pillRegiment: 1, amountOfDaysToTake: 1);
      final pillTaken = PillTaken(
          pillName: "Test Pill", lastTaken: DateTime(2023, 3, 29, 10));

      final String pillsToTakeValue = PillToTake.encode([pill]);
      final String pillsTakenValue = PillTaken.encode([pillTaken]);
      const String otherValue = "some_value";
      const int migrationYear = 2023;

      SharedPreferences.setMockInitialValues({
        "3/29": pillsToTakeValue,
        "pillsTaken3/29": pillsTakenValue,
        "some_other_key": otherValue,
        migratedToYearlyKeysKey: false,
      });

      // Create a new service instance to trigger migration with a fixed year
      await SharedPreferencesService.create(dateService,
          migrationYear: migrationYear);

      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Verify values were migrated correctly
      expect(prefs.getString("$migrationYear/3/29"), pillsToTakeValue);
      expect(prefs.getString("$pillsTakenKey$migrationYear/3/29"),
          pillsTakenValue);

      // Verify old keys were removed
      expect(prefs.containsKey("3/29"), false);
      expect(prefs.containsKey("pillsTaken3/29"), false);

      // Verify unrelated keys were preserved
      expect(prefs.getString("some_other_key"), otherValue);

      // Verify migration flag was set
      expect(prefs.getBool(migratedToYearlyKeysKey), true);
    });

    test("Migration with conflict resolution (merge data)", () async {
      const int migrationYear = 2026;
      const pill1 = PillToTake(
          pillName: "Pill A", pillRegiment: 1, amountOfDaysToTake: 7);
      const pill2 = PillToTake(
          pillName: "Pill B", pillRegiment: 2, amountOfDaysToTake: 7);

      final pillTaken1 = PillTaken(
          pillName: "Pill A",
          lastTaken: DateTime(2026, 3, 29, 10),
          pillImage: "img1");
      final pillTaken2 = PillTaken(
          pillName: "Pill B",
          lastTaken: DateTime(2026, 3, 29, 11),
          pillImage: "img2");

      SharedPreferences.setMockInitialValues({
        "3/29": PillToTake.encode([pill1]),
        "pillsTaken3/29": PillTaken.encode([pillTaken1]),
        "2026/3/29": PillToTake.encode([pill2]),
        "pillsTaken2026/3/29": PillTaken.encode([pillTaken2]),
        migratedToYearlyKeysKey: false,
      });

      await SharedPreferencesService.create(dateService,
          migrationYear: migrationYear);

      final prefs = await SharedPreferences.getInstance();

      final migratedPills =
          PillToTake.decode(prefs.getString("2026/3/29") ?? "");
      final migratedTaken =
          PillTaken.decode(prefs.getString("pillsTaken2026/3/29") ?? "");

      expect(migratedPills.length, 2);
      expect(migratedPills.any((p) => p.pillName == "Pill A"), true);
      expect(migratedPills.any((p) => p.pillName == "Pill B"), true);

      expect(migratedTaken.length, 2);
      expect(migratedTaken.any((p) => p.pillName == "Pill A"), true);
      expect(migratedTaken.any((p) => p.pillName == "Pill B"), true);
    });
  });
}

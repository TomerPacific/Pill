import 'dart:async';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int oneDay = 1;

class SharedPreferencesService {
  late DateService _dateService;
  late SharedPreferences _sharedPreferences;

  SharedPreferencesService._create(DateService dateService) {
    _dateService = dateService;
  }

  static Future<SharedPreferencesService> create(
      DateService dateService) async {
    SharedPreferencesService sharedPreferencesService =
    SharedPreferencesService._create(dateService);

    sharedPreferencesService._sharedPreferences =
    await SharedPreferences.getInstance();

    return sharedPreferencesService;
  }

  // The Future returned by setString is intentionally unawaited: SharedPreferences
  // commits writes to its in-memory cache synchronously before the Future resolves,
  // so subsequent getString calls on the same instance always see the updated value.
  void _setPillsForDate(String currentDate, List<PillToTake> pills) {
    unawaited(
        _sharedPreferences.setString(currentDate, PillToTake.encode(pills)));
  }

  void _setPillsTakenForDate(String date, List<PillTaken> pillsTaken) {
    unawaited(_sharedPreferences.setString(
        pillsTakenKey + date, PillTaken.encode(pillsTaken)));
  }

  List<PillToTake> getPillsToTakeForDate(String currentDate) {
    String? encodedPills = _sharedPreferences.getString(currentDate);
    if (encodedPills != null) {
      return PillToTake.decode(encodedPills);
    }
    return [];
  }

  List<PillTaken> getPillsTakenForDate(String date) {
    String? encodedPills = _sharedPreferences.getString(pillsTakenKey + date);
    if (encodedPills != null) {
      return PillTaken.decode(encodedPills);
    }
    return [];
  }

  // void return: callers should read the specific date they need via
  // getPillsToTakeForDate(date) after this call, since a pill scheduled
  // across multiple days updates each date independently.
  void addPillToDates(DateTime startDate, PillToTake pill) {
    DateTime runningDate = startDate;
    int daysToTake = pill.amountOfDaysToTake;
    final pillWithTrimmedName = pill.copyWith(pillName: pill.pillName.trim());
    while (daysToTake > 0) {
      String dateStr = _dateService.getDateAsMonthAndDay(runningDate);
      List<PillToTake> pills = getPillsToTakeForDate(dateStr);
      pills.add(pillWithTrimmedName);
      _setPillsForDate(dateStr, pills);
      runningDate = runningDate.add(const Duration(days: oneDay));
      daysToTake--;
    }
  }

  void addTakenPill(PillToTake pillTaken, String date) {
    PillTaken pill = PillTaken.extractFromPillToTake(pillTaken);
    List<PillTaken> pillsTaken = getPillsTakenForDate(date);
    pillsTaken.add(pill);
    _setPillsTakenForDate(date, pillsTaken);
  }

  // Returns updated lists for currentDate so the BLoC can emit state without
  // a second read. updatePillForDate only ever modifies a single date, so
  // returning the result here is unambiguous.
  ({List<PillToTake> pillsToTake, List<PillTaken> pillsTaken}) updatePillForDate(
      PillToTake pillToTake, String currentDate) {
    List<PillToTake> pills = getPillsToTakeForDate(currentDate);

    final normalizedName = pillToTake.pillName.trim().toLowerCase();
    int pillIndex = pills.indexWhere(
            (element) => element.pillName.trim().toLowerCase() == normalizedName);

    if (pillIndex == -1) {
      return (
      pillsToTake: pills,
      pillsTaken: getPillsTakenForDate(currentDate)
      );
    }

    final existingPill = pills[pillIndex];
    final pillToSave = pillToTake.copyWith(pillName: existingPill.pillName);

    addTakenPill(pillToSave, currentDate);

    if (pillToSave.pillRegiment == 0) {
      removePillFromDate(pillToSave, currentDate);
      pills = getPillsToTakeForDate(currentDate);
    } else {
      pills[pillIndex] = pillToSave;
      _setPillsForDate(currentDate, pills);
    }

    return (
    pillsToTake: pills,
    pillsTaken: getPillsTakenForDate(currentDate)
    );
  }

  // Returns the updated list for currentDate. removePillFromDate only ever
  // modifies a single date, so the return value is unambiguous.
  List<PillToTake> removePillFromDate(
      PillToTake pillToTake, String currentDate) {
    List<PillToTake> pills = getPillsToTakeForDate(currentDate);
    final normalizedName = pillToTake.pillName.trim().toLowerCase();
    List<PillToTake> updatedPills = pills
        .where((element) =>
    element.pillName.trim().toLowerCase() != normalizedName)
        .toList();
    _setPillsForDate(currentDate, updatedPills);
    return updatedPills;
  }

  void clearAllPillsFromDate(DateTime dateToRemovePillsFrom) {
    DateTime now = DateTime.now();
    DateTime runningDate = dateToRemovePillsFrom;

    while (now.difference(runningDate).inDays >= oneDay) {
      String converted = _dateService.getDateAsMonthAndDay(runningDate);
      _setPillsForDate(converted, []);
      _setPillsTakenForDate(converted, []);
      runningDate = runningDate.add(const Duration(days: oneDay));
    }
  }

  void setTimeWhenApplicationWasOpened() {
    DateTime now = DateTime.now();
    _sharedPreferences.setString(timeAppOpenedKey, now.toIso8601String());
  }

  DateTime? getTimeWhenApplicationWasOpened() {
    String? timeApplicationWasOpened =
    _sharedPreferences.getString(timeAppOpenedKey);
    return timeApplicationWasOpened != null
        ? DateTime.parse(timeApplicationWasOpened)
        : null;
  }

  void clearAllPills() {
    Set<String> keys = _sharedPreferences.getKeys();
    for (String key in keys) {
      if (key.contains(timeAppOpenedKey)) {
        continue;
      }
      _sharedPreferences.remove(key);
    }
  }

  void clearPillsOfPastDays() {
    DateTime? timeWhenApplicationWasOpened = getTimeWhenApplicationWasOpened();
    if (timeWhenApplicationWasOpened == null) {
      setTimeWhenApplicationWasOpened();
    } else {
      DateTime now = DateTime.now();
      if (now.difference(timeWhenApplicationWasOpened).inDays >= oneDay) {
        clearAllPillsFromDate(timeWhenApplicationWasOpened);
        setTimeWhenApplicationWasOpened();
      }
    }
  }

  bool areThereAnyPillsToTake() {
    Set<String> keys = _sharedPreferences.getKeys();
    if (keys.isEmpty) return false;
    for (String key in keys) {
      if (key.contains(RegExp('[0-9]')) && !key.contains(pillsTakenKey)) {
        List<PillToTake> pills = getPillsToTakeForDate(key);
        if (pills.isNotEmpty) return true;
      }
    }
    return false;
  }

  void saveThemeStatus(bool isDarkModeEnabled) {
    _sharedPreferences.setBool(darkModeKey, isDarkModeEnabled);
  }

  bool getThemeStatus() {
    return _sharedPreferences.getBool(darkModeKey) ?? false;
  }
}
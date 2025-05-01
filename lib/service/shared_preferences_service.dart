import 'dart:async';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int ONE_DAY = 1;

class SharedPreferencesService {
  late DateService _dateService;
  late SharedPreferences _sharedPreferences;

  SharedPreferencesService._create(DateService dateService) {
    this._dateService = dateService;
  }

  static Future<SharedPreferencesService> create(
      DateService dateService) async {
    SharedPreferencesService sharedPreferencesService =
        SharedPreferencesService._create(dateService);

    sharedPreferencesService._sharedPreferences =
        await SharedPreferences.getInstance();

    return sharedPreferencesService;
  }

  void _setPillsForDate(String currentDate, List<PillToTake> pills) {
    _sharedPreferences.setString(currentDate, PillToTake.encode(pills));
  }

  void _setPillsTakenForDate(
    String date,
    List<PillTaken> pillsTaken,
  ) {
    _sharedPreferences.setString(
        PILLS_TAKEN_KEY + date, PillTaken.encode(pillsTaken));
  }

  List<PillToTake> getPillsToTakeForDate(String currentDate) {
    String? encodedPills = _sharedPreferences.getString(currentDate);
    List<PillToTake> pills = [];
    if (encodedPills != null) {
      pills = PillToTake.decode(encodedPills);
    }

    return pills;
  }

  List<PillTaken> getPillsTakenForDate(String date) {
    String? encodedPills = _sharedPreferences.getString(PILLS_TAKEN_KEY + date);
    List<PillTaken> pillsTaken = [];
    if (encodedPills != null) {
      pillsTaken = PillTaken.decode(encodedPills);
    }

    return pillsTaken;
  }

  void addPillToDates(String currentDate, PillToTake pill) {
    DateTime runningDate = DateTime.now();

    while (pill.amountOfDaysToTake > 0) {
      List<PillToTake> pills = getPillsToTakeForDate(currentDate);
      pills.add(pill);
      _setPillsForDate(currentDate, pills);
      runningDate = runningDate.add(Duration(days: ONE_DAY));
      currentDate = _dateService.getDateAsMonthAndDay(runningDate);
      pill.amountOfDaysToTake--;
    }
  }

  void addTakenPill(PillToTake pillTaken, String date) {
    PillTaken pill = PillTaken.extractFromPillToTake(pillTaken);
    List<PillTaken> pillsTaken = getPillsTakenForDate(date);
    pillsTaken.add(pill);
    _setPillsTakenForDate(date, pillsTaken);
  }

  void updatePillForDate(PillToTake pillToTake, String currentDate) {
    List<PillToTake> pills = getPillsToTakeForDate(currentDate);
    addTakenPill(pillToTake, currentDate);

    if (pillToTake.pillRegiment == 0) {
      removePillFromDate(pillToTake, currentDate);
    } else {
      int index = pills
          .indexWhere((element) => element.pillName == pillToTake.pillName);
      pills.replaceRange(index, index + 1, [pillToTake]);
      _setPillsForDate(currentDate, pills);
    }
  }

  void removePillFromDate(PillToTake pillToTake, String currentDate) {
    List<PillToTake> pills = getPillsToTakeForDate(currentDate);
    List<PillToTake> updatedPills = pills
        .where((element) => element.pillName != pillToTake.pillName)
        .toList();
    _setPillsForDate(currentDate, updatedPills);
  }

  void clearAllPillsFromDate(DateTime dateToRemovePillsFrom) {
    DateTime date = DateTime.now();
    DateTime runningDate = dateToRemovePillsFrom;

    while (runningDate.difference(date).inDays >= ONE_DAY) {
      String converted = _dateService.getDateAsMonthAndDay(runningDate);
      List<PillToTake> pillsToTake = getPillsToTakeForDate(converted);
      List<PillTaken> pillsTaken = getPillsTakenForDate(converted);

      pillsToTake.clear();
      pillsTaken.clear();

      _setPillsForDate(converted, pillsToTake);
      _setPillsTakenForDate(converted, pillsTaken);
      runningDate = runningDate.add(Duration(days: ONE_DAY));
    }
  }

  void setTimeWhenApplicationWasOpened() {
    DateTime now = DateTime.now();
    _sharedPreferences.setString(TIME_APP_OPENED_KEY, now.toIso8601String());
  }

  DateTime? getTimeWhenApplicationWasOpened() {
    String? timeApplicationWasOpened =
        _sharedPreferences.getString(TIME_APP_OPENED_KEY);
    return timeApplicationWasOpened != null
        ? DateTime.parse(timeApplicationWasOpened)
        : null;
  }

  void clearAllPills() {
    Set<String> keys = _sharedPreferences.getKeys();
    for (String key in keys) {
      if (key.contains(TIME_APP_OPENED_KEY)) {
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
      if (now.difference(timeWhenApplicationWasOpened).inDays >= ONE_DAY) {
        clearAllPillsFromDate(timeWhenApplicationWasOpened);
        setTimeWhenApplicationWasOpened();
      }
    }
  }

  bool areThereAnyPillsToTake() {
    Set<String> keys = _sharedPreferences.getKeys();
    if (keys.isEmpty) return false;
    for (String key in keys) {
      if (key.contains(RegExp('[0-9]')) && !key.contains(PILLS_TAKEN_KEY)) {
        List<PillToTake> pills = getPillsToTakeForDate(key);
        if (pills.isNotEmpty) return true;
      }
    }

    return false;
  }

  void saveThemeStatus(bool isDarkModeEnabled) {
    _sharedPreferences.setBool(DARK_MODE_KEY, isDarkModeEnabled);
  }

  bool getThemeStatus() {
    bool? darkMode = _sharedPreferences.getBool(DARK_MODE_KEY);
    return darkMode != null ? darkMode : false;
  }
}

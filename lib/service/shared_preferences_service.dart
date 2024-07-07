import 'dart:async';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {

  SharedPreferencesService({
    required this.dateService
  });

  final DateService dateService;

  void _setPillsForDate(String currentDate, List<PillToTake> pills) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(currentDate, PillToTake.encode(pills));
  }

  Future<void> _setPillsTakenForDate(String date, List<PillTaken> pillsTaken, ) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(PILLS_TAKEN_KEY+date, PillTaken.encode(pillsTaken));
  }

  Future<List<PillToTake>> getPillsToTakeForDate(String currentDate) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? encodedPills = sharedPreferences.getString(currentDate);
      List<PillToTake> pills = [];
      if (encodedPills != null) {
        pills = PillToTake.decode(encodedPills);
      }

      return pills;
  }

  Future<List<PillTaken>> getPillsTakenForDate(String date) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? encodedPills = sharedPreferences.getString(PILLS_TAKEN_KEY+date);
    List<PillTaken> pillsTaken = [];
    if (encodedPills != null) {
      pillsTaken = PillTaken.decode(encodedPills);
    }

    return pillsTaken;
  }

  Future<void> addPillToDates(String currentDate, PillToTake pill) async {
    DateTime runningDate = DateTime.now();

    while(pill.amountOfDaysToTake > 0) {
      List<PillToTake> pills = await getPillsToTakeForDate(currentDate);
      pills.add(pill);
      _setPillsForDate(currentDate, pills);
      runningDate = runningDate.add(new Duration(days: 1));
      currentDate = dateService.getDateAsMonthAndDay(runningDate);
      pill.amountOfDaysToTake--;
    }

  }

  Future<void> addTakenPill(PillToTake pillTaken, String date) async {
    PillTaken pill = PillTaken.extractFromPillToTake(pillTaken);
    List<PillTaken> pillsTaken = await getPillsTakenForDate(date);
    pillsTaken.add(pill);
    await _setPillsTakenForDate(date, pillsTaken);
  }

  Future<void> updatePillForDate(PillToTake pillToTake, String currentDate) async {
    List<PillToTake> pills = await getPillsToTakeForDate(currentDate);
    await addTakenPill(pillToTake, currentDate);

    if (pillToTake.pillRegiment == 0) {
      removePillFromDate(pillToTake, currentDate);
    } else {
      int index = pills.indexWhere((element) => element.pillName == pillToTake.pillName);
      pills.replaceRange(index, index+1, [pillToTake]);
      _setPillsForDate(currentDate, pills);
    }
  }

  Future<void> removePillFromDate(PillToTake pillToTake, String currentDate) async {
    List<PillToTake> pills = await getPillsToTakeForDate(currentDate);
    List<PillToTake> updatedPills = pills.where((element) => element.pillName != pillToTake.pillName).toList();
    _setPillsForDate(currentDate, updatedPills);
  }

  void clearAllPillsFromDate(DateTime dateToRemovePillsFrom) async {

    DateTime date = DateTime.now();
    DateTime runningDate = dateToRemovePillsFrom;

    while (runningDate.difference(date).inDays >= 1) {
      String converted = dateService.getDateAsMonthAndDay(runningDate);
      List<PillToTake> pillsToTake = await getPillsToTakeForDate(converted);
      List<PillTaken> pillsTaken = await getPillsTakenForDate(converted);

      pillsToTake.clear();
      pillsTaken.clear();

      _setPillsForDate(converted, pillsToTake);
      _setPillsTakenForDate(converted, pillsTaken);
      runningDate = runningDate.add(Duration(days: 1));
    }
  }

  void setTimeWhenApplicationWasOpened() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    DateTime now = DateTime.now();
    sharedPreferences.setString(TIME_APP_OPENED_KEY, now.toIso8601String());
  }

  Future<DateTime?> getTimeWhenApplicationWasOpened() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? timeApplicationWasOpened = sharedPreferences.getString(TIME_APP_OPENED_KEY);
    return timeApplicationWasOpened != null ? DateTime.parse(timeApplicationWasOpened) : null;
  }

  Future<void> clearAllPills() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Set<String> keys = sharedPreferences.getKeys();
    for(String key in keys) {
      if (key.contains(TIME_APP_OPENED_KEY)) {
        continue;
      }
      sharedPreferences.remove(key);
    }
  }

  void clearPillsOfPastDays() async {
    DateTime? timeWhenApplicationWasOpened = await getTimeWhenApplicationWasOpened();
    if (timeWhenApplicationWasOpened == null) {
      setTimeWhenApplicationWasOpened();
    } else {
      DateTime now = DateTime.now();
      if (now.difference(timeWhenApplicationWasOpened).inDays >= 1) {
        clearAllPillsFromDate(timeWhenApplicationWasOpened);
        setTimeWhenApplicationWasOpened();
      }
    }
  }

  Future<bool> areThereAnyPillsToTake() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Set<String> keys = sharedPreferences.getKeys();
    if (keys.isEmpty) return false;
    for (String key in keys) {
      if (key.contains(new RegExp('[0-9]')) && !key.contains(PILLS_TAKEN_KEY)) {
        List<PillToTake> pills = await getPillsToTakeForDate(key);
        if (pills.isNotEmpty) return true;
      }
    }

    return false;
  }

  void saveThemeStatus(bool isDarkModeEnabled) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(DARK_MODE_KEY, isDarkModeEnabled);
  }

  Future<bool> getThemeStatus() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    bool? darkMode = sharedPreferences.getBool(DARK_MODE_KEY);
    return darkMode != null ?
      darkMode :
      false;
  }

}
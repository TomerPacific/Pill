import 'dart:async';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {

  static SharedPreferences? _sharedPreferences;

  factory SharedPreferencesService() => SharedPreferencesService._internal();

  SharedPreferencesService._internal();

  Future<void> init() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
  }

  void _setPillsForDate(String currentDate, List<PillToTake> pills) {
    _sharedPreferences?.setString(currentDate, PillToTake.encode(pills));
  }

  void _setPillsTakenForDate(List<PillTaken> pillsTaken, String date) {
    _sharedPreferences?.setString(PILLS_TAKEN_KEY+date, PillTaken.encode(pillsTaken));
  }

  List<PillToTake> getPillsToTakeForDate(String currentDate) {
      String? encodedPills = _sharedPreferences?.getString(currentDate);
      List<PillToTake> pills = [];
      if (encodedPills != null) {
        pills = PillToTake.decode(encodedPills);
      }

      return pills;
  }

  List<PillTaken> getPillsTakenForDate(String date) {
    String? encodedPills = _sharedPreferences?.getString(PILLS_TAKEN_KEY+date);
    List<PillTaken> pillsTaken = [];
    if (encodedPills != null) {
      pillsTaken = PillTaken.decode(encodedPills);
    }

    return pillsTaken;
  }

  void addPillToDates(String currentDate, PillToTake pill) {
    DateTime runningDate = DateTime.now();

    while(pill.amountOfDaysToTake > 0) {
      List<PillToTake> pills = getPillsToTakeForDate(currentDate);
      pills.add(pill);
      _setPillsForDate(currentDate, pills);
      runningDate = runningDate.add(new Duration(days: 1));
      currentDate = DateService().getDateAsMonthAndDay(runningDate);
      pill.amountOfDaysToTake--;
    }

  }

  void addTakenPill(PillToTake pillTaken, String date) {
    PillTaken pill = PillTaken.extractFromPillToTake(pillTaken);
    List<PillTaken> pillsTaken = getPillsTakenForDate(date);
    pillsTaken.add(pill);
    _setPillsTakenForDate(pillsTaken, date);
  }

  void updatePillForDate(PillToTake pillToTake, String currentDate) {
    List<PillToTake> pills = getPillsToTakeForDate(currentDate);
    int index = pills.indexWhere((element) => element.pillName == pillToTake.pillName);
    addTakenPill(pillToTake, currentDate);
    pills.replaceRange(index, index+1, [pillToTake]);
    _setPillsForDate(currentDate, pills);
  }

  void removePillFromDate(PillToTake pillToTake, String currentDate) {
    List<PillToTake> pills = getPillsToTakeForDate(currentDate);
    List<PillToTake> updatedPills = pills.where((element) => element.pillName != pillToTake.pillName).toList();
    addTakenPill(pillToTake, currentDate);
    _setPillsForDate(currentDate, updatedPills);
  }

  void clearAllPillsFromDate(String dateToRemovePillsFrom) {
    List<PillToTake> pills = getPillsToTakeForDate(dateToRemovePillsFrom);
    pills.clear();
    _setPillsForDate(dateToRemovePillsFrom, pills);
  }

}
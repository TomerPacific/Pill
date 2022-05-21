import 'dart:async';
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

  void _setPillsTaken(List<PillToTake> pillsTaken) {
    _sharedPreferences?.setString(PILLS_TAKEN_KEY, PillToTake.encode(pillsTaken));
  }

  List<PillToTake> getPillsToTakeForDate(String currentDate) {
      String? encodedPills = _sharedPreferences?.getString(currentDate);
      List<PillToTake> pills = [];
      if (encodedPills != null) {
        pills = PillToTake.decode(encodedPills);
      }

      return pills;
  }

  List<PillToTake> getPillsTaken() {
    String? encodedPills = _sharedPreferences?.getString(PILLS_TAKEN_KEY);
    List<PillToTake> pillsTaken = [];
    if (encodedPills != null) {
      pillsTaken = PillToTake.decode(encodedPills);
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

  void addTakenPill(PillToTake pillTaken) {
    List<PillToTake> pillsTaken = getPillsTaken();
    pillsTaken.add(pillTaken);
    _setPillsTaken(pillsTaken);
  }

  void updatePillForDate(PillToTake pillToTake, String currentDate) {
    List<PillToTake> pills = getPillsToTakeForDate(currentDate);
    int index = pills.indexWhere((element) => element.pillName == pillToTake.pillName);
    addTakenPill(pillToTake);
    pills.replaceRange(index, index+1, [pillToTake]);
    _setPillsForDate(currentDate, pills);
  }

  void removePillFromDate(PillToTake pillToTake, String currentDate) {
    List<PillToTake> pills = getPillsToTakeForDate(currentDate);
    List<PillToTake> updatedPills = pills.where((element) => element.pillName != pillToTake.pillName).toList();
    _setPillsForDate(currentDate, updatedPills);
  }

  void clearAllPillsFromDate(String dateToRemovePillsFrom) {
    List<PillToTake> pills = getPillsToTakeForDate(dateToRemovePillsFrom);
    pills.clear();
    _setPillsForDate(dateToRemovePillsFrom, pills);
  }

}
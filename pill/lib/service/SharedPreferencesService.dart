import 'dart:async';
import 'package:pill/model/PillToTake.dart';
import 'package:pill/service/DateService.dart';
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

  List<PillToTake> getPillsToTakeForDate(String currentDate) {
      String? encodedPills = _sharedPreferences?.getString(currentDate);
      List<PillToTake> pills = [];
      if (encodedPills != null) {
        pills = PillToTake.decode(encodedPills);
      }

      return pills;
  }

  void addPillToDates(String currentDate, PillToTake pill) {
    int amountOfDaysToTakePill = pill.amountOfDaysToTake;
    DateTime startDate = DateTime.now();
    for (int day = 0; day < amountOfDaysToTakePill; day++) {
      List<PillToTake> pills = getPillsToTakeForDate(currentDate);
      pills.add(pill);
      _setPillsForDate(currentDate, pills);
      startDate = startDate.add(new Duration(days: 1));
      currentDate = DateService().getDateAsMonthAndDay(startDate);
      pill.amountOfDaysToTake--;
    }
  }

  void removePillAtIndexFromDate(int indexOfPillToRemove, String currentDate) {
    List<PillToTake> pills = getPillsToTakeForDate(currentDate);
    pills.removeAt(indexOfPillToRemove);
    _setPillsForDate(currentDate, pills);
  }

}
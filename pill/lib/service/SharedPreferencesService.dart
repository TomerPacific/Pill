import 'dart:async';
import 'package:pill/model/PillToTake.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {

  static SharedPreferences _sharedPreferences;

  factory SharedPreferencesService() => SharedPreferencesService._internal();

  SharedPreferencesService._internal();

  Future<void> init() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
  }

  void setPillsForDate(String currentDate, List<PillToTake> pills) {
    _sharedPreferences.setString(currentDate, PillToTake.encode(pills));
  }

  List<PillToTake> getPillsToTakeForDate(String currentDate) {
      String encodedPills = _sharedPreferences.getString(currentDate);
      final List<PillToTake> pills = PillToTake.decode(encodedPills);
      return pills;
  }

}
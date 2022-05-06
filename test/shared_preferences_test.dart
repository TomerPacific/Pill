import 'package:flutter_test/flutter_test.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test("SharedPreferences Service get pills for date empty", () {
      List<PillToTake> pills = SharedPreferencesService().getPillsToTakeForDate("5/6");
      expect(pills.length, 0);
  });


}
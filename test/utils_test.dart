
import 'package:flutter_test/flutter_test.dart';
import 'package:pill/utils.dart';

void main() {

  test("Utils convert string into number and it is not greater than zero", () {
      bool result = Utils.isNumberGreaterThanZero("0");
      expect(result, false);
  });

  test("Utils convert string into number and it is greater than zero", () {
    bool result = Utils.isNumberGreaterThanZero("100");
    expect(result, true);
  });

  test("Utils empty string is not greater than zero", () {
    bool result = Utils.isNumberGreaterThanZero("");
    expect(result, false);
  });

  test("Utils null is not greater than zero", () {
    bool result = Utils.isNumberGreaterThanZero(null);
    expect(result, false);
  });
}
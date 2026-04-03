const int ten = 10;

class DateService {
  String getDateAsYearMonthDay(DateTime date) {
    return "${date.year}/${date.month}/${date.day}";
  }

  String getHourFromDate(DateTime dateTime) {
    String hour =
        dateTime.hour < ten ? "0${dateTime.hour}" : "${dateTime.hour}";
    String minutes = _convertDigitToStringWithPadding(dateTime.minute);
    String seconds = _convertDigitToStringWithPadding(dateTime.second);
    return "$hour:$minutes:$seconds";
  }

  String _convertDigitToStringWithPadding(int digit) {
    return digit < ten ? "0$digit" : "$digit";
  }

  String getCurrentDateAsYearMonthDay() {
    return getDateAsYearMonthDay(DateTime.now());
  }
}

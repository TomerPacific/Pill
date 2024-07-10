class DateService {
  final int TEN = 10;

  String getDateAsMonthAndDay(DateTime date) {
    return date.month.toString() + "/" + date.day.toString();
  }

  String getHourFromDate(DateTime dateTime) {
    String hour =
        dateTime.hour < TEN ? "0${dateTime.hour}" : "${dateTime.hour}";
    String minutes = _convertDigitToStringWithPadding(dateTime.minute);
    String seconds = _convertDigitToStringWithPadding(dateTime.second);
    return "$hour:$minutes:$seconds";
  }

  String _convertDigitToStringWithPadding(int digit) {
    return digit < TEN ? "0$digit" : "$digit";
  }

  String getCurrentDateAsMonthAndDay() {
    return getDateAsMonthAndDay(DateTime.now());
  }
}

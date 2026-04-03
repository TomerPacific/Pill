const int ten = 10;

class DateService {
  /// Returns a date string formatted as "YYYY/M/D", suitable for storage keys.
  String formatDateForStorage(DateTime date) {
    return "${date.year}/${date.month}/${date.day}";
  }

  /// Returns a date string formatted as "M/D" for user-facing display.
  String formatDateForDisplay(DateTime date) {
    return "${date.month}/${date.day}";
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

  @Deprecated('Use formatDateForStorage(DateTime.now())')
  String getCurrentDateAsYearMonthDay() {
    return formatDateForStorage(DateTime.now());
  }

  @Deprecated('Use formatDateForStorage or formatDateForDisplay')
  String getDateAsYearMonthDay(DateTime date) {
    return formatDateForStorage(date);
  }
}

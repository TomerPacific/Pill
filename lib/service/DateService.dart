
class DateService {
  static final DateService instance = DateService._internal();

  factory DateService() {
    return instance;
  }

  DateService._internal();

  String getDateAsMonthAndDay(DateTime date) {
    return date.month.toString() + "/" + date.day.toString();
  }

  String getHourFromDate(DateTime dateTime) {
    return "${dateTime.hour}:${dateTime.minute}:${dateTime.second}";
  }
}
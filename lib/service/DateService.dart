
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
    String hour = dateTime.hour < 10 ? "0${dateTime.hour}" : "${dateTime.hour}";
    String minutes = dateTime.minute < 10 ? "0${dateTime.minute}" : "${dateTime.minute}";
    String seconds = dateTime.second < 10 ? "0${dateTime.second}" : "${dateTime.second}";
    return "$hour:$minutes:$seconds";
  }
}
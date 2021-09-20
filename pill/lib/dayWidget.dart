
import 'package:flutter/cupertino.dart';
import 'package:pill/service/DateService.dart';

class DayWidget extends StatefulWidget {

  DayWidget({Key key, this.date}): super(key: key);

  final DateTime date;

  @override
  State<StatefulWidget> createState() {
    return DayWidgetState();
  }
}

class DayWidgetState extends State<DayWidget> {


  @override
  Widget build(BuildContext context) {
      return new Container(
        child:
          new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new Text(
                  DateService().getDateAsMonthAndDay(widget.date),
                  style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)
              )
            ],
        ),
      );
  }

}
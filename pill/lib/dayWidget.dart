
import 'package:flutter/cupertino.dart';

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
                  widget.date.month.toString() + "/" + widget.date.day.toString(),
                  style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)
              )
            ],
        ),
      );
  }

}
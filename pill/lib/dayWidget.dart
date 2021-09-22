
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
            new Expanded(
                child: new SizedBox(
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      new Align(
                        alignment: Alignment.topCenter,
                        child:  new Text(
                            DateService().getDateAsMonthAndDay(widget.date),
                            style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)
                        ),
                      )
                    ],
                  ),
                )
            )
      );
  }

}
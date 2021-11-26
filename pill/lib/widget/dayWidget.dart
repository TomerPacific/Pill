
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pill/model/PillToTake.dart';
import 'package:pill/service/DateService.dart';
import 'package:pill/service/SharedPreferencesService.dart';
import 'package:pill/widget/pillWidget.dart';

class DayWidget extends StatefulWidget {

  DayWidget({Key key, this.date}): super(key: key);

  final DateTime date;

  @override
  State<StatefulWidget> createState() {
    return DayWidgetState();
  }
}

class DayWidgetState extends State<DayWidget> {

  List<PillToTake> _pillsToTake = List.empty();

  @override void initState() {
    String currentDate = DateService().getDateAsMonthAndDay(widget.date);
    _pillsToTake = SharedPreferencesService().getPillsToTakeForDate(currentDate);
    super.initState();
  }

  void updatePillsAfterAddition() {
    String currentDate = DateService().getDateAsMonthAndDay(widget.date);
    setState(() {
      _pillsToTake = SharedPreferencesService().getPillsToTakeForDate(currentDate);
    });

  }

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
                        child:  new Padding(
                            padding: const EdgeInsets.only(
                                top:8.0
                            ),
                          child: new Text(
                              DateService().getDateAsMonthAndDay(widget.date),
                              style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          new Expanded(
                              child:  new Align(
                                alignment: Alignment.center,
                                  child:  new Text(
                                    "Pill Name    Pill Regiment    Information",
                                    style:  new TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent
                                    ),
                                  )
                          ),
                          ),
                        ],
                      ),
                      _pillsToTake.length == 0 ?
                      new Text("You do not have to take any pills today.") :
                          ListView.builder(
                            shrinkWrap: true,
                              itemCount: _pillsToTake.length,
                              itemBuilder:
                                  (_, index) =>
                                    new PillWidget(pillToTake: _pillsToTake[index])
                          )
                    ],
                  ),
                )
            )
      );
  }

}
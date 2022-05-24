import 'package:flutter/material.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/service/date_service.dart';

class PillTakenWidget extends StatelessWidget {

  const PillTakenWidget({
    required this.pillToTake}) : super();

  final PillTaken pillToTake;

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Card(
        child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        new Text(
                          pillToTake.pillName,
                          style:  new TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold
                          ),
                        )
                      ]
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                          pillToTake.pillImage,
                          width: 100,
                          height: 100
                      )
                    ],
                  ),
                  new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                      [
                        Icon(Icons.access_time),
                        new Text(
                            DateService().getHourFromDate(pillToTake.lastTaken!),
                            style:  new TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold
                            )
                        )
                      ]
                  )
                ]
            )
        ),
      ),
    );
  }

}
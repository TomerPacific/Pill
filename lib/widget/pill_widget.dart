
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill_event.dart';
import 'package:pill/bloc/pill_bloc.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';

class PillWidget extends StatelessWidget {

  const PillWidget({
    required this.pillToTake}) : super();

  final PillToTake pillToTake;

  void _handleOnTap(BuildContext context) {
    pillToTake.pillRegiment--;
    if (pillToTake.pillRegiment == 0) {
        context.read<PillBloc>().add(DeletePill(pillToTake: pillToTake));
    } else {
      pillToTake.lastTaken = DateTime.now();
      context.read<PillBloc>().add(UpdatePill(pillToTake: pillToTake));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Card(
            child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  _handleOnTap(context);
                },
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
                        children: [
                          new Text(
                              "Pills left to take today: ${pillToTake.pillRegiment}",
                              style:  new TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                              )
                          )
                        ],
                      ),
                      new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: pillToTake.lastTaken != null ?
                          [
                            Icon(Icons.access_time),
                            new Text(
                              DateService().getHourFromDate(pillToTake.lastTaken!),
                              style:  new TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                              )
                          )
                          ] : []
                      )

                    ]
                )
            ),
          ),
    );
  }

}
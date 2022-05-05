
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill_event.dart';
import 'package:pill/bloc/pill_bloc.dart';
import 'package:pill/model/PillToTake.dart';
import 'package:pill/service/DateService.dart';

class PillWidget extends StatefulWidget {

  const PillWidget({
    required this.pillToTake}) : super();

  final PillToTake pillToTake;

  @override
  State<StatefulWidget> createState() {
    return PillWidgetState();
  }

}

class PillWidgetState extends State<PillWidget> {

  int _amountOfPillsLeftToTakeToday = 0;

  void _handleOnTap(BuildContext context) {
    setState(() {
      _amountOfPillsLeftToTakeToday = --_amountOfPillsLeftToTakeToday;
    });
    widget.pillToTake.lastTaken = DateTime.now();
    widget.pillToTake.pillRegiment = _amountOfPillsLeftToTakeToday;

    if (_amountOfPillsLeftToTakeToday == 0) {
        context.read<PillBloc>().add(DeletePill(pillToTake: widget.pillToTake));
    } else {
      context.read<PillBloc>().add(UpdatePill(pillToTake: widget.pillToTake));
    }
  }

  @override
  void initState() {
    _amountOfPillsLeftToTakeToday = widget.pillToTake.pillRegiment;
    super.initState();
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
                              widget.pillToTake.pillName,
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
                              widget.pillToTake.pillImage,
                              width: 100,
                              height: 100
                          )
                        ],
                      ),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          new Text(
                              "Pills left to take today: $_amountOfPillsLeftToTakeToday",
                              style:  new TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                              )
                          )
                        ],
                      ),
                      new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: widget.pillToTake.lastTaken != null ?
                          [new Text(
                              "Last time pill was taken: " + DateService().getHourFromDate(widget.pillToTake.lastTaken!),
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
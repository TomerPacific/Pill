
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

  void _handleOnTap(BuildContext context) {
    setState(() {
      widget.pillToTake.pillRegiment = --widget.pillToTake.pillRegiment;
    });

    if (widget.pillToTake.pillRegiment == 0) {
        context.read<PillBloc>().add(DeletePill(pillToTake: widget.pillToTake));
    } else {
      widget.pillToTake.lastTaken = DateTime.now();
      context.read<PillBloc>().add(UpdatePill(pillToTake: widget.pillToTake));
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
                              "Pills left to take today: ${widget.pillToTake.pillRegiment}",
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
                          [
                            Icon(Icons.access_time),
                            new Text(
                              DateService().getHourFromDate(widget.pillToTake.lastTaken!),
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pill/model/PillToTake.dart';

class PillWidget extends StatefulWidget {

  const PillWidget({
    required this.pillToTake, required this.onPillRegimentMetHandler
  }) : super();

  final PillToTake pillToTake;
  final Function onPillRegimentMetHandler;

  @override
  State<StatefulWidget> createState() {
    return PillWidgetState();
  }

}

class PillWidgetState extends State<PillWidget> {

  int _amountOfPillsLeftToTakeToday = 0;

  void _handleOnTap() {
    setState(() {
      _amountOfPillsLeftToTakeToday = --_amountOfPillsLeftToTakeToday;
    });

    if (_amountOfPillsLeftToTakeToday == 0) {
      widget.onPillRegimentMetHandler(widget.pillToTake);
    }
  }

  @override
  void initState() {
    _amountOfPillsLeftToTakeToday = int.parse(widget.pillToTake.pillRegiment);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Card(
            child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: _handleOnTap,
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
                      )
                    ]
                )
            ),
          ),
    );
  }

}
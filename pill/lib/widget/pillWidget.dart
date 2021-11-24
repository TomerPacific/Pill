
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pill/model/PillToTake.dart';

class PillWidget extends StatelessWidget {

  const PillWidget({
    Key key,
    @required this.pillToTake
  }) : super(key: key);

  final PillToTake pillToTake;

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.greenAccent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          new Text(
            this.pillToTake.pillName,
            style:  new TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold
            ),
          )
        ],
      )
    );
  }

}
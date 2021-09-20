
import 'package:flutter/cupertino.dart';

class PillWidget extends StatelessWidget {

  Future<void> _init() async {

  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: FutureBuilder<void>(
       builder: (context, snapshot) {
         return new Text(
             "Pill Data"
          );
        },
        future: _init(),
      )
    );
  }

}
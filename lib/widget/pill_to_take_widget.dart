import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/bloc/theme/theme_block.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';

class PillWidget extends StatelessWidget {
  const PillWidget({required this.pillToTake, required this.dateService}) : super();

  final PillToTake pillToTake;
  final DateService dateService;

  void _handleOnTap(BuildContext context) {
    pillToTake.pillRegiment--;
    pillToTake.lastTaken = DateTime.now();
    context.read<PillBloc>().add(PillsEvent(
        eventName: PillEvent.updatePill,
        date: dateService.getCurrentDateAsMonthAndDay(),
        pillToTake: pillToTake));
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
                          style: new TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                        )
                      ]),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(pillToTake.pillImage,
                          width: 100,
                          height: 100,
                          color:
                              context.read<ThemeBloc>().state == ThemeMode.light
                                  ? const Color(0xFF000000)
                                  : const Color(0xFFFFFFFF))
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      new Text(
                          "Pills left to take today: ${pillToTake.pillRegiment}",
                          style: new TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold))
                    ],
                  ),
                  new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: pillToTake.lastTaken != null
                          ? [
                              Icon(Icons.access_time),
                              new Text(
                                  dateService
                                      .getHourFromDate(pillToTake.lastTaken!),
                                  style: new TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold))
                            ]
                          : [])
                ])),
      ),
    );
  }
}

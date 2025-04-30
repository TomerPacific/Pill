import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/bloc/theme/theme_block.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';

class PillWidget extends StatelessWidget {
  const PillWidget({required this.pillToTake, required this.dateService})
      : super();

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
    return Container(
      child: Card(
        child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              _handleOnTap(context);
            },
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  pillToTake.pillName,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                )
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(pillToTake.pillImage,
                      width: 100,
                      height: 100,
                      color: context.read<ThemeBloc>().state == ThemeMode.light
                          ? const Color(0xFF000000)
                          : const Color(0xFFFFFFFF))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Pills left to take today: ${pillToTake.pillRegiment}",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold))
                ],
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: pillToTake.lastTaken != null
                      ? [
                          Icon(Icons.access_time),
                          Text(
                              dateService
                                  .getHourFromDate(pillToTake.lastTaken!),
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold))
                        ]
                      : [])
            ])),
      ),
    );
  }
}

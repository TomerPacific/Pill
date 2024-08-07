import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/bloc/pill/pill_state.dart';
import 'package:pill/constants.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/widget/pill_taken_widget.dart';
import 'package:pill/widget/pill_to_take_widget.dart';

class DayWidget extends StatelessWidget {
  DayWidget(
      {required this.date, required this.header, required this.dateService});

  final DateTime date;
  final String header;
  final DateService dateService;

  Widget _pillsToTakeList(BuildContext context, PillState state) {
    return (state.pillsToTake == null || state.pillsToTake!.isEmpty)
        ? new Padding(
            padding: const EdgeInsets.only(top: 20),
            child: new Text(header,
                style:
                    new TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))
        : Expanded(
            child: SizedBox(
            height: 200.0,
            child: ListView.builder(
                itemCount: state.pillsToTake!.length,
                itemBuilder: (_, index) => new Dismissible(
                    key: ObjectKey(state.pillsToTake![index].pillName),
                    child: new PillWidget(
                      pillToTake: state.pillsToTake![index],
                      dateService: dateService,
                    ),
                    onDismissed: (direction) {
                      context.read<PillBloc>().add(PillsEvent(
                          eventName: PillEvent.removePill,
                          date: dateService.getDateAsMonthAndDay(date),
                          pillToTake: state.pillsToTake![index],
                          pillsToTake: state.pillsToTake,
                          pillsTaken: state.pillsTaken));
                    })),
          ));
  }

  Widget _pillsTakenList(BuildContext context, PillState state) {
    return (state.pillsTaken == null || state.pillsTaken!.isEmpty)
        ? new Padding(
            padding: const EdgeInsets.only(top: 20),
            child: new Text(header,
                style:
                    new TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))
        : Expanded(
            child: SizedBox(
                height: 200.0,
                child: ListView.builder(
                  itemCount: state.pillsTaken!.length,
                  itemBuilder: (_, index) => new PillTakenWidget(
                      pillToTake: state.pillsTaken![index],
                      dateService: dateService),
                )),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: new Expanded(
            child: new SizedBox(
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          new Align(
            alignment: Alignment.topCenter,
            child: new Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: new Text(dateService.getDateAsMonthAndDay(date),
                  style: new TextStyle(
                      fontSize: 25.0, fontWeight: FontWeight.bold)),
            ),
          ),
          (this.header == PILLS_TO_TAKE_HEADER)
              ? _pillsToTakeList(context, context.read<PillBloc>().state)
              : _pillsTakenList(context, context.read<PillBloc>().state)
        ],
      ),
    )));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/bloc/pill/pill_state.dart';
import 'package:pill/constants.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/widget/pill_taken_widget.dart';
import 'package:pill/widget/pill_to_take_widget.dart';

const double listItemHeight = 200.0;

class DayWidget extends StatelessWidget {
  const DayWidget(
      {super.key,
      required this.date,
      required this.header,
      required this.dateService});

  final DateTime date;
  final String header;
  final DateService dateService;

  Widget _pillsToTakeList(BuildContext context, PillState state) {
    List<PillToTake>? pillsToTake = state.pillsToTake;
    return (pillsToTake == null || pillsToTake.isEmpty)
        ? Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(header,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))
        : Expanded(
            child: SizedBox(
            height: listItemHeight,
            child: ListView.builder(
                itemCount: pillsToTake.length,
                itemBuilder: (_, index) => Dismissible(
                    key: ObjectKey(pillsToTake[index].pillName),
                    child: PillWidget(
                      pillToTake: pillsToTake[index],
                      dateService: dateService,
                    ),
                    onDismissed: (direction) {
                      context.read<PillBloc>().add(PillsEvent(
                          eventName: PillEvent.removePill,
                          date: dateService.getDateAsMonthAndDay(date),
                          pillToTake: pillsToTake[index],
                          pillsToTake: pillsToTake,
                          pillsTaken: state.pillsTaken));
                    })),
          ));
  }

  Widget _pillsTakenList(BuildContext context, PillState state) {
    List<PillTaken>? pillsTaken = state.pillsTaken;
    if (pillsTaken == null || pillsTaken.isEmpty) {
      return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(header,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));
    }

    return Expanded(
      child: SizedBox(
          height: listItemHeight,
          child: ListView.builder(
            itemCount: pillsTaken.length,
            itemBuilder: (_, index) => PillTakenWidget(
                pillTaken: pillsTaken[index], dateService: dateService),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SizedBox(
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text(dateService.getDateAsMonthAndDay(date),
                  style: const TextStyle(
                      fontSize: 25.0, fontWeight: FontWeight.bold)),
            ),
          ),
          (header == pillsToTakeHeader)
              ? _pillsToTakeList(context, context.read<PillBloc>().state)
              : _pillsTakenList(context, context.read<PillBloc>().state)
        ],
      ),
    ));
  }
}

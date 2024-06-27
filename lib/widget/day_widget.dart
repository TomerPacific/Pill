
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/bloc/pill/pill_state.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/widget/pill_taken_widget.dart';
import 'package:pill/widget/pill_to_take_widget.dart';

class DayWidget extends StatelessWidget {

  DayWidget({required this.date, required this.title});

  final DateTime date;
  final String title;

  Widget _buildPillList(BuildContext context, List<dynamic> pills) {
    if (pills is List<PillToTake> && pills.length > 0) {
      return Expanded(
          child: SizedBox(
            height: 200.0,
            child:  ListView.builder(
                itemCount: pills.length,
                itemBuilder:
                    (_, index) =>
                new Dismissible(
                    key: ObjectKey(pills[index].pillName),
                    child: new PillWidget(pillToTake: pills[index]),
                    onDismissed: (direction) {
                      context.read<PillBloc>().add(PillsEvent(
                          eventName: PillEvent.removePill,
                          date: date.toString(),
                          pillToTake: pills[index]));
                      //state.pillsToTake.removeAt(index);
                    }
                )
            ),
          )
      );
    } else if (pills is List<PillTaken> && pills.length > 0) {
      return Expanded(
          child: SizedBox(
            height: 200.0,
            child:  ListView.builder(
                itemCount: pills.length,
                itemBuilder:
                    (_, index) =>
                    new PillTakenWidget(pillToTake: pills[index]),
                )
            ),
          );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PillBloc, PillState>(
      builder: (context, state) {
        return new Container(
            child:
            new Expanded(
                child: new SizedBox(
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      new Align(
                        alignment: Alignment.topCenter,
                        child:  new Padding(
                          padding: const EdgeInsets.only(
                              top:40.0
                          ),
                          child: new Text(
                              DateService().getDateAsMonthAndDay(date),
                              style: new TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),
                      (state.pillsToTake == null || state.pillsToTake!.isEmpty) ?
                        new Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: new Text(
                                title,
                                style: new TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                            )
                        )
                      :
                      Expanded(
                          child: SizedBox(
                            height: 200.0,
                            child:  ListView.builder(
                                itemCount: state.pillsToTake!.length,
                                itemBuilder:
                                    (_, index) =>
                                new Dismissible(
                                    key: ObjectKey(state.pillsToTake![index].pillName),
                                    child: new PillWidget(pillToTake: state.pillsToTake![index]),
                                    onDismissed: (direction) {
                                      context.read<PillBloc>().add(PillsEvent(
                                          eventName: PillEvent.removePill,
                                          date: date.toString(),
                                          pillToTake: state.pillsToTake![index]));
                                      //state.pillsToTake.removeAt(index);
                                    }
                                )
                            ),
                          )
                      )
                    ],
                  ),
                )
            )
        );
      },
    );
  }

}
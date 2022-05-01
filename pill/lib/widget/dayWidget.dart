
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill_state.dart';
import 'package:pill/bloc/pill_bloc.dart';
import 'package:pill/service/DateService.dart';
import 'package:pill/widget/pillWidget.dart';

import '../bloc/pill_event.dart';

class DayWidget extends StatelessWidget {

  DayWidget({required this.date});

  final DateTime date;

  Widget drawPills(BuildContext context, PillState state) {
    if (state is PillLoading) {
      return const CircularProgressIndicator();
    }
    if (state is PillLoaded) {
      return state.pillsToTake.length == 0 ?
      new Padding(
          padding: const EdgeInsets.only(top: 20),
          child: new Text(
              "You do not have to take any pills today 😀",
              style: new TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
          )
      )
          :
      Expanded(
          child: SizedBox(
            height: 200.0,
            child:  ListView.builder(
                itemCount: state.pillsToTake.length,
                itemBuilder:
                    (_, index) =>
                new Dismissible(
                    key: ObjectKey(state.pillsToTake[index].pillName),
                    child: new PillWidget(pillToTake: state.pillsToTake[index]),
                    onDismissed: (direction) {
                      context.read<PillBloc>().add(DeletePill(pillToTake: state.pillsToTake[index]));
                      //state.pillsToTake.removeAt(index);
                    }
                )
            ),
          )
      );
    }
    else {
      return const Text("Something went wrong");
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
                      drawPills(context, state),
                    ],
                  ),
                )
            )
        );
      },
    );
  }

}
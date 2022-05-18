
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/bloc/pill/pill_event.dart';
import 'package:pill/bloc/pill_filter/pill_filter_bloc.dart';
import 'package:pill/bloc/pill_filter/pill_filter_state.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/widget/pill_widget.dart';

class DayWidget extends StatelessWidget {

  DayWidget({required this.date});

  final DateTime date;

  Widget drawPills(BuildContext context, PillFilterState state) {
    if (state is PillFilterLoading) {
      return const CircularProgressIndicator();
    }
    if (state is PillFilterLoaded) {
      return state.filteredPills.length == 0 ?
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
                itemCount: state.filteredPills.length,
                itemBuilder:
                    (_, index) =>
                new Dismissible(
                    key: ObjectKey(state.filteredPills[index].pillName),
                    child: new PillWidget(pillToTake: state.filteredPills[index]),
                    onDismissed: (direction) {
                      context.read<PillBloc>().add(DeletePill(pillToTake: state.filteredPills[index]));
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
    return BlocBuilder<PillFilterBloc, PillFilterState>(
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
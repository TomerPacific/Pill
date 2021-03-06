
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/bloc/pill/pill_event.dart';
import 'package:pill/bloc/pill_filter/pill_filter_bloc.dart';
import 'package:pill/bloc/pill_filter/pill_filter_state.dart';
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
                      context.read<PillBloc>().add(DeletePill(pillToTake: pills[index]));
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

  Widget _drawPills(BuildContext context, PillFilterState state) {
    if (state is PillFilterLoading) {
      return const CircularProgressIndicator();
    }
    if (state is PillFilterLoaded) {
      List<dynamic> pills = state.filteredPills;
      return pills.length == 0 ?
      new Padding(
          padding: const EdgeInsets.only(top: 20),
          child: new Text(
             title,
              style: new TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
          )
      )
          :
      _buildPillList(context, pills);
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
                      _drawPills(context, state),
                    ],
                  ),
                )
            )
        );
      },
    );
  }

}
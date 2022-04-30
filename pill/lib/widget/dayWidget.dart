
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/PillState.dart';
import 'package:pill/bloc/pill_bloc.dart';
import 'package:pill/model/PillToTake.dart';
import 'package:pill/service/DateService.dart';
import 'package:pill/service/SharedPreferencesService.dart';
import 'package:pill/widget/pillWidget.dart';

class DayWidget extends StatefulWidget {

  DayWidget({required Key key, required this.date}): super(key: key);

  final DateTime date;

  @override
  State<StatefulWidget> createState() {
    return DayWidgetState();
  }
}

class DayWidgetState extends State<DayWidget> {

  List<PillToTake> _pillsToTake = List.empty();

  @override void initState() {
    String currentDate = DateService().getDateAsMonthAndDay(widget.date);
    _pillsToTake = SharedPreferencesService().getPillsToTakeForDate(currentDate);
    super.initState();
  }

  void updatePillsAfterAddition() {
    String currentDate = DateService().getDateAsMonthAndDay(widget.date);
    setState(() {
      _pillsToTake = SharedPreferencesService().getPillsToTakeForDate(currentDate);
    });

  }

  void removePillWhenDailyRegimentHasBeenMet(PillToTake pill) {
    String currentDate = DateService().getDateAsMonthAndDay(widget.date);
    int indexOfPillToRemove = _pillsToTake.indexWhere((element) => element.equals(pill));
    SharedPreferencesService().removePillAtIndexFromDate(indexOfPillToRemove, currentDate);

    setState(() {
      _pillsToTake.removeAt(indexOfPillToRemove);
    });
  }

  Widget drawPills(PillState state) {
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
                  child: new PillWidget(pillToTake: state.pillsToTake[index], onPillRegimentMetHandler: removePillWhenDailyRegimentHasBeenMet),
                  onDismissed: (direction) {
                    setState(() {
                      SharedPreferencesService().removePillAtIndexFromDate(
                          index, DateService().getDateAsMonthAndDay(widget.date)
                      );
                      state.pillsToTake.removeAt(index);
                    });
                  },
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
                              DateService().getDateAsMonthAndDay(widget.date),
                              style: new TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),
                      drawPills(state),
                    ],
                  ),
                )
            )
        );
      },
    );
  }

}
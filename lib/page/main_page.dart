import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/clearPills/ClearPillsBloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/bloc/pill/pill_state.dart';
import 'package:pill/constants.dart';
import 'package:pill/custom_icons.dart';
import 'package:pill/page/settings_page.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:pill/widget/day_widget.dart';
import 'package:pill/widget/adding_pill_form.dart';

class MainPage extends StatefulWidget {
  MainPage(
      {required this.title,
      required this.sharedPreferencesService,
      required this.dateService})
      : super();

  final String title;
  final SharedPreferencesService sharedPreferencesService;
  final DateService dateService;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  void _handleAddPillButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddingPillForm(DateTime.now())),
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<PillBloc>(context).add(new PillsEvent(
        eventName: PillEvent.loadPills,
        date: widget.dateService.getCurrentDateAsMonthAndDay()));
    widget.sharedPreferencesService.clearPillsOfPastDays();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: AMOUNT_OF_TABS,
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: AppBar(
                bottom: TabBar(
                  tabs: [
                    Tab(icon: Icon(CustomIcons.pill)),
                    Tab(icon: Icon(Icons.watch_later_rounded)),
                    Tab(icon: Icon(Icons.settings)),
                  ],
                  onTap: (tabIndex) {
                    switch (tabIndex) {
                      case 0:
                      case 1:
                        context.read<PillBloc>().add(PillsEvent(
                            eventName: PillEvent.loadPills,
                            date: widget.dateService
                                .getCurrentDateAsMonthAndDay()));
                        break;
                      case 2:
                        context
                            .read<ClearPillsBloc>()
                            .add(ClearPillsEvent.PillsUpdated);
                    }
                  },
                  //controller: _controller,
                ),
              ),
            ),
            body: TabBarView(children: [
              BlocBuilder<PillBloc, PillState>(builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new DayWidget(
                        date: DateTime.now(),
                        header: PILLS_TO_TAKE_HEADER,
                        dateService: widget.dateService),
                    new Align(
                      alignment: Alignment.bottomRight,
                      child: new Padding(
                        padding: EdgeInsets.all(10.0),
                        child: new FloatingActionButton(
                            onPressed: _handleAddPillButtonPressed,
                            child: Icon(Icons.add)),
                      ),
                    )
                  ],
                );
              }),
              BlocBuilder<PillBloc, PillState>(builder: (context, state) {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new DayWidget(
                          date: DateTime.now(),
                          header: PILLS_TAKEN_HEADER,
                          dateService: widget.dateService),
                    ]);
              }),
              BlocBuilder<ClearPillsBloc, bool>(builder: (context, state) {
                return SettingsPage(
                    sharedPreferencesService: widget.sharedPreferencesService);
              })
            ])));
  }
}

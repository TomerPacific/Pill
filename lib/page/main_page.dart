import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/clearPills/ClearPillsBloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/constants.dart';
import 'package:pill/custom_icons.dart';
import 'package:pill/page/settings_page.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:pill/widget/day_widget.dart';
import 'package:pill/widget/adding_pill_form.dart';

class MainPage extends StatefulWidget {
  MainPage({
    required this.title,
    required this.sharedPreferencesService,
    required this.dateService})
      : super();

  final String title;
  final SharedPreferencesService sharedPreferencesService;
  final DateService dateService;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

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
        eventName: PillEvent.loadPillsToTake,
        date: widget.dateService.getCurrentDateAsMonthAndDay()));
    widget.sharedPreferencesService.clearPillsOfPastDays();
    _controller = TabController(length: 3, vsync: this);
    _controller.addListener(() {
      switch (_controller.index) {
        case 0:
          context.read<PillBloc>().add(PillsEvent(
              eventName: PillEvent.loadPillsToTake,
              date: widget.dateService.getCurrentDateAsMonthAndDay()));
          break;
        case 1:
          context.read<PillBloc>().add(PillsEvent(
              eventName: PillEvent.loadTakenPills,
              date: widget.dateService.getCurrentDateAsMonthAndDay()));
          break;
        case 2:
          context.read<ClearPillsBloc>().add(ClearPillsEvent.PillsUpdated);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(CustomIcons.pill)),
                Tab(icon: Icon(Icons.watch_later_rounded)),
                Tab(icon: Icon(Icons.settings)),
              ],
              controller: _controller,
            ),
          ),
        ),
        body: TabBarView(controller: _controller, children: [
          Column(
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
                  child:
                    new FloatingActionButton(
                    onPressed: _handleAddPillButtonPressed,
                  child: Icon(Icons.add)),
                ),
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new DayWidget(
                  date: DateTime.now(),
                  header: PILLS_TAKEN_HEADER,
                  dateService: widget.dateService),
            ],
          ),
           SettingsPage(
                sharedPreferencesService: widget.sharedPreferencesService)
        ]));
  }
}

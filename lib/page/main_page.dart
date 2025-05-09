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

const int PILLS_TO_TAKE_TAB_INDEX = 0;
const int PILLS_TAKEN_TAB_INDEX = 1;
const int SETTINGS_TAB_INDEX = 2;

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
  @override
  void initState() {
    super.initState();
    BlocProvider.of<PillBloc>(context).add(PillsEvent(
        eventName: PillEvent.loadPills,
        date: widget.dateService.getCurrentDateAsMonthAndDay()));
    widget.sharedPreferencesService.clearPillsOfPastDays();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: AMOUNT_OF_TABS,
        child: Scaffold(
            appBar: _mainPageAppBar(context, widget.dateService),
            body: _mainPageTabBarView(
                widget.dateService, widget.sharedPreferencesService)));
  }
}

PreferredSizeWidget _mainPageAppBar(
  BuildContext context,
  DateService dateService,
) {
  return PreferredSize(
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
            case PILLS_TO_TAKE_TAB_INDEX:
            case PILLS_TAKEN_TAB_INDEX:
              context.read<PillBloc>().add(PillsEvent(
                  eventName: PillEvent.loadPills,
                  date: dateService.getCurrentDateAsMonthAndDay()));
              break;
            case SETTINGS_TAB_INDEX:
              context
                  .read<ClearPillsBloc>()
                  .add(ClearPillsEvent.UpdatePillsStatus);
          }
        },
      ),
    ),
  );
}

TabBarView _mainPageTabBarView(DateService dateService,
    SharedPreferencesService sharedPreferencesService) {
  return TabBarView(children: [
    BlocBuilder<PillBloc, PillState>(builder: (context, state) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          DayWidget(
              date: DateTime.now(),
              header: PILLS_TO_TAKE_HEADER,
              dateService: dateService),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddingPillForm(DateTime.now())),
                    );
                  },
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
            DayWidget(
                date: DateTime.now(),
                header: PILLS_TAKEN_HEADER,
                dateService: dateService),
          ]);
    }),
    BlocBuilder<ClearPillsBloc, bool>(builder: (context, state) {
      return SettingsPage(sharedPreferencesService: sharedPreferencesService);
    })
  ]);
}

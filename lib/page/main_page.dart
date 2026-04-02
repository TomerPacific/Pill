import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/clearPills/clear_pills_bloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/constants.dart';
import 'package:pill/custom_icons.dart';
import 'package:pill/page/settings_page.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:pill/widget/day_widget.dart';
import 'package:pill/widget/adding_pill_form.dart';

const int pillsToTakeTabIndex = 0;
const int pillsTakenTabIndex = 1;
const int settingsTabIndex = 2;

class MainPage extends StatefulWidget {
  const MainPage(
      {super.key,
      required this.title,
      required this.sharedPreferencesService,
      required this.dateService});

  final String title;
  final SharedPreferencesService sharedPreferencesService;
  final DateService dateService;

  @override
  State<MainPage> createState() => _MainPageState();
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
        length: amountOfTabs,
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
    preferredSize: const Size.fromHeight(50),
    child: AppBar(
      bottom: TabBar(
        tabs: const [
          Tab(icon: Icon(CustomIcons.pill)),
          Tab(icon: Icon(Icons.watch_later_rounded)),
          Tab(icon: Icon(Icons.settings)),
        ],
        onTap: (tabIndex) {
          switch (tabIndex) {
            case pillsToTakeTabIndex:
            case pillsTakenTabIndex:
              context.read<PillBloc>().add(PillsEvent(
                  eventName: PillEvent.loadPills,
                  date: dateService.getCurrentDateAsMonthAndDay()));
              break;
            case settingsTabIndex:
              context
                  .read<ClearPillsBloc>()
                  .add(ClearPillsEvent.updatePillsStatus);
          }
        },
      ),
    ),
  );
}

TabBarView _mainPageTabBarView(DateService dateService,
    SharedPreferencesService sharedPreferencesService) {
  return TabBarView(children: [
    Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        DayWidget(
            date: DateTime.now(),
            mode: DayWidgetMode.toTake,
            dateService: dateService),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Builder(builder: (context) {
              return FloatingActionButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => AddingPillForm(DateTime.now()));
                  },
                  child: const Icon(Icons.add));
            }),
          ),
        )
      ],
    ),
    Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      DayWidget(
          date: DateTime.now(),
          mode: DayWidgetMode.taken,
          dateService: dateService),
    ]),
    BlocBuilder<ClearPillsBloc, bool>(builder: (context, state) {
      return SettingsPage(sharedPreferencesService: sharedPreferencesService);
    })
  ]);
}

import 'dart:async';
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
      required this.sharedPreferencesService,
      required this.dateService});

  final SharedPreferencesService sharedPreferencesService;
  final DateService dateService;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  late DateTime _now;
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _now = widget.dateService.now();
    _loadPillsForToday();
    unawaited(widget.sharedPreferencesService.clearPillsOfPastDays());
    _scheduleMidnightRefresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnightTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadPillsForToday();
      _scheduleMidnightRefresh();
    }
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now = widget.dateService.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final duration = nextMidnight.difference(now);

    // Add a 1-second buffer to ensure we've crossed the boundary
    _midnightTimer = Timer(duration + const Duration(seconds: 1), () {
      if (mounted) {
        _loadPillsForToday();
        _scheduleMidnightRefresh();
      }
    });
  }

  void _loadPillsForToday() {
    final now = widget.dateService.now();
    final todayStr = widget.dateService.formatDateForStorage(now);
    final displayedStr = widget.dateService.formatDateForStorage(_now);

    if (todayStr != displayedStr) {
      setState(() {
        _now = now;
      });
    }

    context.read<PillBloc>().add(PillsEvent(
        eventName: PillEvent.loadPills,
        date: todayStr));
  }

  void _updateNow([DateTime? now]) {
    setState(() {
      _now = now ?? widget.dateService.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: amountOfTabs,
        child: Scaffold(
            appBar: _MainPageAppBar(
              key: const ValueKey('MainPageAppBar'),
              onPillsTabTapped: _loadPillsForToday,
              onSettingsTabTapped: () {
                context
                    .read<ClearPillsBloc>()
                    .add(ClearPillsEvent.updatePillsStatus);
              },
            ),
            body: _MainPageTabBarView(
              key: const ValueKey('MainPageTabBarView'),
              now: _now,
              dateService: widget.dateService,
              sharedPreferencesService: widget.sharedPreferencesService,
              onAddPillTapped: (updatedNow) => _updateNow(updatedNow),
            )));
  }
}

class _MainPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onPillsTabTapped;
  final VoidCallback onSettingsTabTapped;

  const _MainPageAppBar({
    super.key,
    required this.onPillsTabTapped,
    required this.onSettingsTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 0,
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
              onPillsTabTapped();
              break;
            case settingsTabIndex:
              onSettingsTabTapped();
              break;
          }
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}

class _MainPageTabBarView extends StatelessWidget {
  final DateTime now;
  final DateService dateService;
  final SharedPreferencesService sharedPreferencesService;
  final ValueChanged<DateTime> onAddPillTapped;

  const _MainPageTabBarView({
    super.key,
    required this.now,
    required this.dateService,
    required this.sharedPreferencesService,
    required this.onAddPillTapped,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          DayWidget(
              date: now,
              mode: DayWidgetMode.toTake,
              dateService: dateService),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: FloatingActionButton(
                  onPressed: () {
                    final updatedNow = dateService.now();
                    onAddPillTapped(updatedNow);
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => AddingPillForm(
                            pillDate: updatedNow,
                            sharedPreferencesService:
                                sharedPreferencesService,
                            dateService: dateService));
                  },
                  child: const Icon(Icons.add)),
            ),
          )
        ],
      ),
      Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        DayWidget(
            date: now,
            mode: DayWidgetMode.taken,
            dateService: dateService),
      ]),
      BlocBuilder<ClearPillsBloc, bool>(builder: (context, state) {
        return SettingsPage(
            sharedPreferencesService: sharedPreferencesService);
      })
    ]);
  }
}

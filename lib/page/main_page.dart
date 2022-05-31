import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill_filter/pill_filter_bloc.dart';
import 'package:pill/bloc/pill_filter/pill_filter_event.dart';
import 'package:pill/custom_icons.dart';
import 'package:pill/model/pill_filter.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:pill/widget/day_widget.dart';
import 'package:pill/widget/adding_pill_form.dart';

class MainPage extends StatefulWidget {
  MainPage({required this.title}) : super();

  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {

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
    SharedPreferencesService().clearPillsOfPastDays();
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener(() {
      switch(_controller.index) {
        case 0:
          context.read<PillFilterBloc>().add(UpdatePills(pillFilter: PillFilter.all));
          break;
        case 1:
          context.read<PillFilterBloc>().add(UpdatePills(pillFilter: PillFilter.taken));
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
                  onTap: (tabIndex) {
                    switch(tabIndex) {
                      case 0:
                        BlocProvider.of<PillFilterBloc>(context)
                            .add(const UpdatePills(
                            pillFilter: PillFilter.all
                        ));
                        break;
                      case 1:
                        BlocProvider.of<PillFilterBloc>(context)
                            .add(const UpdatePills(
                            pillFilter: PillFilter.taken
                        ));
                        break;
                    }
                  }, tabs: [
                  Tab(icon: Icon(CustomIcons.pill)),
                  Tab(icon: Icon(Icons.watch_later_rounded)),
                ],
                controller: _controller,
              ),
            ),
          ),
          body: TabBarView(
            controller: _controller,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new DayWidget(
                      date: DateTime.now(),
                      title:  "You do not have to take any pills today 😀"
                  ),
                  new Align(
                    alignment: Alignment.bottomRight,
                    child: new FloatingActionButton(
                        onPressed: _handleAddPillButtonPressed,
                        child: Icon(Icons.add)
                    ),
                  )

                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new DayWidget(
                      date: DateTime.now(),
                      title:  "You have not taken any pills today"),
                ],
              ),
            ],
          ),
        );
  }
}

import 'package:flutter/material.dart';
import 'package:pill/widget/day_widget.dart';
import 'package:pill/widget/adding_pill_form.dart';

class MainPage extends StatefulWidget {
  MainPage({required this.title}) : super();

  final String title;

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new DayWidget(date: DateTime.now()
          )
        ],
      ),
      floatingActionButton: new FloatingActionButton(
          onPressed: _handleAddPillButtonPressed,
          child: Icon(Icons.add)
      ),
    );
  }
}

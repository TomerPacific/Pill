import 'package:flutter/material.dart';
import 'package:pill/widget/dayWidget.dart';
import 'package:pill/widget/addingPillForm.dart';

class MainPage extends StatefulWidget {
  MainPage({required this.title}) : super();

  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  final GlobalKey<DayWidgetState> _key = GlobalKey();

  void _handleAddPillButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddingPillForm(DateTime.now())),
    ).then((value) {
      _key.currentState?.updatePillsAfterAddition();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new DayWidget(
              key: _key,
              date: DateTime.now()
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

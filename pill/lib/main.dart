import 'package:flutter/material.dart';
import 'widget/addingPillForm.dart';
import 'widget/dayWidget.dart';
import 'package:pill/service/SharedPreferencesService.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesService().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pill',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Pill'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required this.title}) : super();

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final GlobalKey<DayWidgetState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
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
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddingPillForm(DateTime.now())),
          ).then((value) {
            _key.currentState?.updatePillsAfterAddition();
          }),
          child: Icon(Icons.add)
        ),
      );
  }
}

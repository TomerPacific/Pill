import 'package:flutter/material.dart';
import 'package:pill/constants.dart';
import 'package:pill/page/main_page.dart';
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
      title: APP_TITLE,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(title: APP_TITLE),
    );
  }
}

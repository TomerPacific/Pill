import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill_filter/pill_filter_bloc.dart';
import 'bloc/pill/pill_event.dart';
import 'bloc/pill/pill_bloc.dart';
import 'package:pill/constants.dart';
import 'package:pill/page/main_page.dart';
import 'package:pill/service/shared_preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesService().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [BlocProvider(
          create: (context) => PillBloc()
            ..add(LoadPill(),),
        ),
        BlocProvider(create:
        (context) => PillFilterBloc(pillBloc: BlocProvider.of<PillBloc>(context)
            ),
          ),
        ],
        child: MaterialApp(
      title: APP_TITLE,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
        home: MainPage(title: APP_TITLE),
      )
    );
  }
}

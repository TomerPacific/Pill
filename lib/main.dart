import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/clearPills/ClearPillsBloc.dart';
import 'package:pill/bloc/theme/theme_block.dart';
import 'package:pill/service/date_service.dart';
import 'bloc/pill/pill_bloc.dart';
import 'package:pill/constants.dart';
import 'package:pill/page/main_page.dart';
import 'package:pill/service/shared_preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DateService dateService = DateService();
  SharedPreferencesService sharedPreferencesService =
      await SharedPreferencesService.create(dateService);
  bool isDarkMode = await sharedPreferencesService.getThemeStatus();
  runApp(MyApp(
      sharedPreferencesService: sharedPreferencesService,
      dateService: dateService,
      isDarkMode: isDarkMode));
}

class MyApp extends StatelessWidget {
  MyApp(
      {required this.sharedPreferencesService,
      required this.dateService,
      required this.isDarkMode});

  final SharedPreferencesService sharedPreferencesService;
  final DateService dateService;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PillBloc(sharedPreferencesService),
        ),
        BlocProvider(
            create: (context) =>
                ThemeBloc(sharedPreferencesService, isDarkMode)),
        BlocProvider(
            create: (context) => ClearPillsBloc(sharedPreferencesService)),
      ],
      child: BlocBuilder<ThemeBloc, ThemeMode>(builder: (context, state) {
        return MaterialApp(
          title: APP_TITLE,
          theme: ThemeData(primarySwatch: Colors.blue),
          darkTheme: ThemeData.dark(),
          themeMode: state,
          home: MainPage(
              title: APP_TITLE,
              sharedPreferencesService: sharedPreferencesService,
              dateService: dateService),
        );
      }),
    );
  }
}

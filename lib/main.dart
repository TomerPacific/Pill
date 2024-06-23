import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill_filter/pill_filter_bloc.dart';
import 'package:pill/bloc/theme/theme_block.dart';
import 'bloc/pill/pill_event.dart';
import 'bloc/pill/pill_bloc.dart';
import 'package:pill/constants.dart';
import 'package:pill/page/main_page.dart';
import 'package:pill/service/shared_preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferencesService sharedPreferencesService = SharedPreferencesService();
  bool isDarkMode = await sharedPreferencesService.getThemeStatus();
  runApp(
      MyApp(sharedPreferencesService: sharedPreferencesService, isDarkMode: isDarkMode)
  );
}

class MyApp extends StatelessWidget {

  MyApp({
    required this.sharedPreferencesService,
    required this.isDarkMode
  });

  final SharedPreferencesService sharedPreferencesService;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PillBloc()
            ..add(LoadPill(),),
        ),
        BlocProvider(
          create: (context) => PillFilterBloc(pillBloc: BlocProvider.of<PillBloc>(context)
          ),
        ),
        BlocProvider(
            create: (context) => ThemeBloc(sharedPreferencesService, isDarkMode)
        ),
      ],
      child:
      BlocBuilder<ThemeBloc, ThemeMode>(
          builder: (context, state) {
            return MaterialApp(
              title: APP_TITLE,
              theme: ThemeData(primarySwatch: Colors.blue),
              darkTheme: ThemeData.dark(),
              themeMode:  state,
              home: MainPage(title: APP_TITLE),
            );
          }
      ),
    );
  }
}

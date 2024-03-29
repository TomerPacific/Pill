import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/bloc/pill/pill_event.dart';
import 'package:pill/bloc/theme/theme_block.dart';
import 'package:pill/bloc/theme/theme_event.dart';
import 'package:pill/service/shared_preferences_service.dart';

class SettingsPage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SwitchListTile(
              title: const Text("Dark Mode"),
              secondary: new Icon(
                  Icons.dark_mode,
                  color: BlocProvider.of<ThemeBloc>(context).state.isDarkModeEnabled ?
                  Color.fromARGB(200, 243, 231, 106) :
                  Color(0xFF642ef3)
              ),
              value: BlocProvider.of<ThemeBloc>(context).state.isDarkModeEnabled,
              onChanged: (bool isDarkModeEnabled) {
                BlocProvider.of<ThemeBloc>(context).add(ChangeTheme(darkThemeEnabled: isDarkModeEnabled));
              }),
          ListTile(
              title: const Text("Clear All Pills"),
              leading: const Icon(
                  Icons.clear,
                  color: Colors.redAccent),
              enabled: SharedPreferencesService().areThereAnyPillsToTake(),
              onTap: () {
                AlertDialog alertDialog = AlertDialog(
                  title: const Text("Clear All Saved Pills"),
                  content: const Text("Are you sure you want to remove all your saved pills?"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          BlocProvider.of<PillBloc>(context).add(ClearAllPills());
                          Navigator.pop(context);
                        },
                        child: const Text("Yes")
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("No")
                    ),
                  ],
                );
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alertDialog;
                    });
              }
          ),
        ]
    );
  }
}
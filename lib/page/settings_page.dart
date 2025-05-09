import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/clearPills/ClearPillsBloc.dart';
import 'package:pill/bloc/theme/theme_block.dart';
import 'package:pill/service/shared_preferences_service.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({required this.sharedPreferencesService});

  final SharedPreferencesService sharedPreferencesService;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      SwitchListTile(
          title: const Text("Dark Mode"),
          secondary: new Icon(Icons.dark_mode,
              color: _getThemeColorForDarkModeSetting(context)),
          value:
              context.read<ThemeBloc>().state == ThemeMode.dark ? true : false,
          onChanged: (bool isDarkModeEnabled) {
            ThemeEvent event = context.read<ThemeBloc>().state == ThemeMode.dark
                ? ThemeEvent.enableLightMode
                : ThemeEvent.enableDarkMode;
            BlocProvider.of<ThemeBloc>(context).add(event);
          }),
      ListTile(
          title: const Text("Clear All Pills"),
          leading: const Icon(Icons.clear, color: Colors.redAccent),
          enabled: context.read<ClearPillsBloc>().state,
          onTap: () {
            AlertDialog alertDialog = _createClearAllPillsAlertDialog(context);
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alertDialog;
                });
          }),
    ]);
  }
}

Color _getThemeColorForDarkModeSetting(BuildContext context) {
  return context.read<ThemeBloc>().state == ThemeMode.dark
      ? Color.fromARGB(200, 243, 231, 106)
      : Color(0xFF642ef3);
}

AlertDialog _createClearAllPillsAlertDialog(BuildContext context) {
  return AlertDialog(
    title: const Text("Clear All Saved Pills"),
    content:
        const Text("Are you sure you want to remove all your saved pills?"),
    actions: [
      TextButton(
          onPressed: () {
            BlocProvider.of<ClearPillsBloc>(context)
                .add(ClearPillsEvent.ClearAllPills);
            Navigator.pop(context);
          },
          child: const Text("Yes")),
      TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("No")),
    ],
  );
}

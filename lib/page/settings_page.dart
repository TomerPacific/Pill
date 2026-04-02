import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/clearPills/clear_pills_bloc.dart';
import 'package:pill/bloc/theme/theme_block.dart';
import 'package:pill/service/shared_preferences_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.sharedPreferencesService});

  final SharedPreferencesService sharedPreferencesService;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, themeMode) {
          return SwitchListTile(
              title: const Text("Dark Mode"),
              secondary: Icon(Icons.dark_mode,
                  color: themeMode == ThemeMode.dark
                      ? const Color.fromARGB(200, 243, 231, 106)
                      : const Color(0xFF642ef3)),
              value: themeMode == ThemeMode.dark,
              onChanged: (bool isDarkModeEnabled) {
                ThemeEvent event = themeMode == ThemeMode.dark
                    ? ThemeEvent.enableLightMode
                    : ThemeEvent.enableDarkMode;
                context.read<ThemeBloc>().add(event);
              });
        },
      ),
      BlocBuilder<ClearPillsBloc, bool>(
        builder: (context, clearPillsEnabled) {
          return ListTile(
              title: const Text("Clear All Pills"),
              leading: const Icon(Icons.clear, color: Colors.redAccent),
              enabled: clearPillsEnabled,
              onTap: () {
                AlertDialog alertDialog = _createClearAllPillsAlertDialog(context);
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alertDialog;
                    });
              });
        },
      ),
    ]);
  }
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
                .add(ClearPillsEvent.clearAllPills);
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

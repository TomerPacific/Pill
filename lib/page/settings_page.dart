import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/bloc/pill/pill_event.dart';

class SettingsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ListTile(
                      title: const Text("Clear All Pills"),
                      leading: const Icon(
                          Icons.clear,
                          color: Colors.redAccent),
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
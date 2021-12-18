
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pill/model/PillToTake.dart';
import 'package:pill/service/SharedPreferencesService.dart';
import 'package:pill/service/DateService.dart';

class AddingPillForm extends StatefulWidget {

  final DateTime currentDate;

  const AddingPillForm(this.currentDate);

  @override
  AddingPillFormState createState() {
    return AddingPillFormState();
  }
}

class AddingPillFormState extends State<AddingPillForm> {
  final _formKey = GlobalKey<FormState>();
  final pillNameTextEditingController = TextEditingController();
  String pillRegiment = "1";

  @override void dispose() {
    pillNameTextEditingController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: pillNameTextEditingController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'What is the pill\'s name?'
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a pill name';
                }
                return null;
              }
            ),
            DropdownButtonFormField<String>(
                value: "1",
                decoration: InputDecoration(
                  labelText: 'How Much To Take Per Day'
                ),
                hint: new Text("How Much To Take Per Day"),
                onChanged: (value) => {
                  if (value != null) {
                    pillRegiment = value
                  }
                },
                items: [
                  DropdownMenuItem<String>(
                      value: "1",
                      child: new Text("1")
                  ),
                  DropdownMenuItem<String>(
                      value: "2",
                      child: new Text("2")
                  ),
                  DropdownMenuItem<String>(
                      value: "3",
                      child: new Text("3")
                  )
                ],
                  validator: (value) {
                    if (value == null || value.isEmpty || value == "0") {
                      return 'Please choose a pill regiment';
                    }

                    return null;
                  },
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                    alignment: Alignment.topLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          PillToTake pill = new PillToTake(
                              pillName: pillNameTextEditingController.text,
                              pillWeight: 0.0,
                              pillRegiment: pillRegiment,
                              description: '');

                          SharedPreferencesService().addPillToDate(
                              DateService().getDateAsMonthAndDay(widget.currentDate),
                              pill
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Submit'),
                    )
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
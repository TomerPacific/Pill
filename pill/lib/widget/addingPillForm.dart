
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

final _formKey = GlobalKey<FormState>();

class AddingPillFormState extends State<AddingPillForm> {

  final pillNameTextEditingController = TextEditingController();
  final pillAmountOfDaysToTakeController = TextEditingController();
  final pillRegimentController = TextEditingController();

  @override void dispose() {
    pillNameTextEditingController.dispose();
    pillAmountOfDaysToTakeController.dispose();
    pillRegimentController.dispose();
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
            TextFormField(
                controller: pillRegimentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'How many pills to take per day?'
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a number representing the amount of pills to take';
                  }
                  return null;
                }
            ),
            TextFormField(
                controller: pillAmountOfDaysToTakeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'For How Many Days?'
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a number representing the number of days';
                  }
                  return null;
                }
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
                              pillRegiment: int.parse(pillRegimentController.text),
                              description: '',
                              amountOfDaysToTake: int.parse(pillAmountOfDaysToTakeController.text));

                          SharedPreferencesService().addPillToDates(
                              DateService().getDateAsMonthAndDay(widget.currentDate),
                              pill
                          );
                          FocusScope.of(context).unfocus();
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
                      FocusScope.of(context).unfocus();
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pill/constants.dart';
import 'package:pill/custom_icons_icons.dart';
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
      body:
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(ADDING_A_PILL_TITLE,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)
          ),
          SizedBox(height: 25.0),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: TextFormField(
                      controller: pillNameTextEditingController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'What is the pill\'s name?',
                          prefixIcon: Icon(CustomIcons.pill)
                          // prefixIcon: Icon(Icons.title)
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a pill name';
                        }
                        return null;
                      }
                  ),
                ),
                SizedBox(height: 25.0),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child:  TextFormField(
                      controller: pillRegimentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'How many pills to take per day?',
                          prefixIcon: Icon(Icons.confirmation_number)
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a number representing the amount of pills to take';
                        }
                        return null;
                      }
                  ),
                ),
                SizedBox(height: 25.0),
                Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child:  TextFormField(
                        controller: pillAmountOfDaysToTakeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'For How Many Days?',
                            prefixIcon: Icon(Icons.calendar_today)
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a number representing the number of days';
                          }
                          return null;
                        }
                    ),
                ),
                SizedBox(height: 25.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(onPressed: () {
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
                    } ,
                        icon: Icon(Icons.check, color: Colors.lightGreen),
                        label: const Text(ADD_PILL_FORM_CONFIRM)
                    ),
                   ElevatedButton.icon(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.clear, color: Colors.red),
                        label: const Text(ADD_PILL_FORM_CANCEL),
                      ),
                  ],
                )
              ],
            ),
          ),
        ],
      )
    );
  }
}

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
  String pillName = "";
  String pillRegiment = "1";
  bool showPillRegimentDropDown = false;
  final FocusNode focusNode = FocusNode();

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
              },
              onFieldSubmitted: (v){
                setState(() {
                  showPillRegimentDropDown = true;
                  pillName = v;
                });
                FocusScope.of(context).requestFocus(focusNode);
              },
            ),
            Visibility(
              visible: showPillRegimentDropDown,
                child: DropdownButtonFormField<String>(
                value: "1",
                decoration: InputDecoration(
                  labelText: 'How Much To Take Per Day'
                ),
                hint: new Text("How Much To Take Per Day"),
                onChanged: (value) => {
                  pillRegiment = value
                },
                focusNode: focusNode,
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
                ]
              )
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                    alignment: Alignment.topLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          PillToTake pill = new PillToTake(
                              pillName: pillName,
                              pillWeight: 0.0,
                              pillRegiment: pillRegiment,
                              description: '');

                          SharedPreferencesService().addPillToDate(
                              DateService().getDateAsMonthAndDay(widget.currentDate),
                              pill
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pill Added'))
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pill/model/PillRegiment.dart';
import 'package:pill/model/PillToTake.dart';

class AddingPillForm extends StatefulWidget {
  const AddingPillForm({Key key}) : super(key: key);

  @override
  AddingPillFormState createState() {
    return AddingPillFormState();
  }
}

class AddingPillFormState extends State<AddingPillForm> {
  final _formKey = GlobalKey<FormState>();
  final pillNameTextEditingController = TextEditingController();
  String pillName = "";
  PillRegiment pillRegiment = PillRegiment.Daily;
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
                value: pillRegiment.toString(),
                decoration: InputDecoration(
                  labelText: 'Choose Pill Regiment'
                ),
                hint: new Text("Choose Pill Regiment"),
                onChanged: (value) => {
                  pillRegiment = PillRegiment.values.firstWhere((e) => e.toString() == value)
                },
                focusNode: focusNode,
                items: [
                  DropdownMenuItem<String>(
                      value: PillRegiment.Daily.toString(),
                      child: new Text("Daily")
                  ),
                  DropdownMenuItem<String>(
                      value: PillRegiment.Weekly.toString(),
                      child: new Text("Weekly")
                  ),
                  DropdownMenuItem<String>(
                      value: PillRegiment.Monthly.toString(),
                      child: new Text("Monthly")
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pill Added')),
                          );
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
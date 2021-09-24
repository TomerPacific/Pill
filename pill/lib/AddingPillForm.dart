
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  String pillRegiment = "Daily";


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
            ),
            DropdownButtonFormField<String>(
                value: pillRegiment,
                hint: new Text("Choose Pill Regiment"),
                onChanged: (value) => pillRegiment = value,
                items: [
                  DropdownMenuItem<String>(
                      value: 'Daily',
                      child: new Text("Daily")
                  ),
                  DropdownMenuItem<String>(
                      value: 'Weekly',
                      child: new Text("Weekly")
                  ),
                  DropdownMenuItem<String>(
                      value: 'Monthly',
                      child: new Text("Monthly")
                  )
                ]
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
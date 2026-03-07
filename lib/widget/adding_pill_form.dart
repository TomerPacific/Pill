import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill/pill_state.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/constants.dart';
import 'package:pill/custom_icons.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/utils.dart';

class AddingPillForm extends StatefulWidget {
  final DateTime _currentDate;

  const AddingPillForm(this._currentDate);

  @override
  AddingPillFormState createState() {
    return AddingPillFormState();
  }
}

class AddingPillFormState extends State<AddingPillForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _pillNameTextEditingController;
  late final TextEditingController _pillAmountOfDaysToTakeController;
  late final TextEditingController _pillRegimentController;
  late final TextEditingController _pillDescriptionController;

  @override
  void initState() {
    super.initState();
    _pillNameTextEditingController = TextEditingController();
    _pillAmountOfDaysToTakeController =
        TextEditingController(text: DEFAULT_PILL_DAYS);
    _pillRegimentController =
        TextEditingController(text: DEFAULT_PILL_REGIMENT);
    _pillDescriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _pillNameTextEditingController.dispose();
    _pillAmountOfDaysToTakeController.dispose();
    _pillRegimentController.dispose();
    _pillDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ADDING_A_PILL_TITLE,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
            SizedBox(height: 25.0),
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: <Widget>[
                  TextFormField(
                      key: ObjectKey("pillName"),
                      controller: _pillNameTextEditingController,
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 1),
                          ),
                          hintText: 'What is the pill\'s name?',
                          prefixIcon:
                              Icon(CustomIcons.pill, color: Colors.red)),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(
                            r'^[\p{L}\s]*$',
                            multiLine: false,
                            caseSensitive: true,
                            unicode: true)),
                        FilteringTextInputFormatter.singleLineFormatter
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a pill name';
                        }
                        return null;
                      }),
                  SizedBox(height: 20.0),
                  TextFormField(
                      key: ObjectKey("pillRegiment"),
                      controller: _pillRegimentController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'How many pills per day?',
                          prefixIcon: Icon(Icons.confirmation_number,
                              color: Colors.blue)),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !Utils.isNumberGreaterThanZero(value)) {
                          return 'Please enter a number';
                        }
                        return null;
                      }),
                  SizedBox(height: 20.0),
                  TextFormField(
                      key: ObjectKey("pillDays"),
                      controller: _pillAmountOfDaysToTakeController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.green, width: 1),
                          ),
                          hintText: 'For How Many Days?',
                          prefixIcon:
                              Icon(Icons.calendar_today, color: Colors.green)),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !Utils.isNumberGreaterThanZero(value)) {
                          return 'Please enter a number';
                        }
                        return null;
                      }),
                  SizedBox(height: 20.0),
                  TextFormField(
                      key: ObjectKey("pillDescription"),
                      controller: _pillDescriptionController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Instructions (optional)',
                          prefixIcon:
                              Icon(Icons.description, color: Colors.orange)),
                      validator: (value) {
                        return null;
                      }),
                  SizedBox(height: 25.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              PillToTake pill = PillToTake(
                                  pillName: _pillNameTextEditingController.text,
                                  pillRegiment:
                                      int.parse(_pillRegimentController.text),
                                  description: _pillDescriptionController.text,
                                  amountOfDaysToTake: int.parse(
                                      _pillAmountOfDaysToTakeController.text));

                              context.read<PillBloc>().add(PillsEvent(
                                  eventName: PillEvent.addPill,
                                  date: DateService().getDateAsMonthAndDay(
                                      widget._currentDate),
                                  startDateTime: widget._currentDate,
                                  pillToTake: pill));

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: const Text("Pill Added!")),
                              );

                              FocusScope.of(context).unfocus();
                              Navigator.pop(context);
                            }
                          },
                          icon: Icon(Icons.check, color: Colors.lightGreen),
                          label: const Text(ADD_PILL_FORM_CONFIRM)),
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
        ),
      ),
    );
  }
}

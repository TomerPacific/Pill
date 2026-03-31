import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/constants.dart';
import 'package:pill/custom_icons.dart';
import 'package:pill/model/pill_duration.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/utils.dart';

class AddingPillForm extends StatefulWidget {
  final DateTime _currentDate;

  const AddingPillForm(this._currentDate, {super.key});

  @override
  AddingPillFormState createState() {
    return AddingPillFormState();
  }
}

class AddingPillFormState extends State<AddingPillForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _pillNameTextEditingController;
  late final TextEditingController _pillAmountOfDaysToTakeController;
  late final TextEditingController _pillDescriptionController;

  final FocusNode _pillNameFocusNode = FocusNode();
  final FocusNode _pillDaysFocusNode = FocusNode();

  PillDuration _selectedDuration = PillDuration.sevenDays;
  int _pillsPerDay = 1;

  @override
  void initState() {
    super.initState();
    _pillNameTextEditingController = TextEditingController();
    _pillAmountOfDaysToTakeController =
        TextEditingController(text: defaultPillDays);
    _pillDescriptionController = TextEditingController();

    _pillsPerDay = int.tryParse(defaultPillRegiment) ?? 1;

    if (defaultPillDays == "7") {
      _selectedDuration = PillDuration.sevenDays;
    } else if (defaultPillDays == "14") {
      _selectedDuration = PillDuration.fourteenDays;
    } else if (defaultPillDays == "30") {
      _selectedDuration = PillDuration.oneMonth;
    } else {
      _selectedDuration = PillDuration.custom;
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _pillNameFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _pillNameTextEditingController.dispose();
    _pillAmountOfDaysToTakeController.dispose();
    _pillDescriptionController.dispose();
    _pillNameFocusNode.dispose();
    _pillDaysFocusNode.dispose();
    super.dispose();
  }

  void _onDurationChanged(PillDuration selection) {
    if (_selectedDuration == selection) return;
    setState(() {
      _selectedDuration = selection;
      if (selection == PillDuration.sevenDays) {
        _pillAmountOfDaysToTakeController.text = "7";
      } else if (selection == PillDuration.fourteenDays) {
        _pillAmountOfDaysToTakeController.text = "14";
      } else if (selection == PillDuration.oneMonth) {
        _pillAmountOfDaysToTakeController.text = "30";
      } else {
        _pillAmountOfDaysToTakeController.clear();
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _pillDaysFocusNode.requestFocus();
        });
      }
    });
  }

  void _incrementPills() {
    setState(() {
      _pillsPerDay++;
    });
  }

  void _decrementPills() {
    if (_pillsPerDay > 1) {
      setState(() {
        _pillsPerDay--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(addingAPillTitle,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20.0)),
            const SizedBox(height: 25.0),
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: <Widget>[
                  TextFormField(
                      key: const ValueKey("pillName"),
                      controller: _pillNameTextEditingController,
                      focusNode: _pillNameFocusNode,
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
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a pill name';
                        }

                        // Duplicate prevention check
                        final pillBloc = context.read<PillBloc>();
                        final existingPills = pillBloc.state.pillsToTake ?? [];
                        final normalizedValue = value.trim().toLowerCase();
                        if (existingPills.any((p) =>
                            p.pillName.trim().toLowerCase() == normalizedValue)) {
                          return 'This pill is already in your list';
                        }

                        return null;
                      }),
                  const SizedBox(height: 20.0),
                  Row(
                    children: [
                      const Icon(Icons.confirmation_number, color: Colors.blue),
                      const SizedBox(width: 12),
                      const Text("Pills per day:",
                          style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      IconButton(
                        onPressed: _decrementPills,
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.blue),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          _pillsPerDay.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: _incrementPills,
                        icon: const Icon(Icons.add_circle_outline,
                            color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                      child: Text("Duration",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<PillDuration>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                            value: PillDuration.sevenDays, label: Text('7d')),
                        ButtonSegment(
                            value: PillDuration.fourteenDays,
                            label: Text('14d')),
                        ButtonSegment(
                            value: PillDuration.oneMonth, label: Text('30d')),
                        ButtonSegment(
                            value: PillDuration.custom, label: Text('Custom')),
                      ],
                      selected: {_selectedDuration},
                      onSelectionChanged: (Set<PillDuration> newSelection) {
                        _onDurationChanged(newSelection.first);
                      },
                    ),
                  ),
                  if (_selectedDuration == PillDuration.custom)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                          key: const ValueKey("pillDays"),
                          controller: _pillAmountOfDaysToTakeController,
                          focusNode: _pillDaysFocusNode,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.green, width: 1),
                              ),
                              hintText: 'Number of days',
                              prefixIcon: Icon(Icons.calendar_today,
                                  color: Colors.green)),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !Utils.isNumberGreaterThanZero(value)) {
                              return 'Please enter a number';
                            }
                            return null;
                          }),
                    ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                      key: const ValueKey("pillDescription"),
                      controller: _pillDescriptionController,
                      textInputAction: TextInputAction.done,
                      maxLines: 3,
                      minLines: 1,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Instructions (optional)',
                          prefixIcon:
                              Icon(Icons.description, color: Colors.orange)),
                      validator: (value) {
                        return null;
                      }),
                  const SizedBox(height: 25.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              final trimmedDescription =
                                  _pillDescriptionController.text.trim();

                              PillToTake pill = PillToTake(
                                  pillName: _pillNameTextEditingController.text
                                      .trim(),
                                  pillRegiment: _pillsPerDay,
                                  description: trimmedDescription.isEmpty
                                      ? ''
                                      : trimmedDescription,
                                  amountOfDaysToTake: int.parse(
                                      _pillAmountOfDaysToTakeController.text));

                              context.read<PillBloc>().add(PillsEvent(
                                  eventName: PillEvent.addPill,
                                  date: DateService().getDateAsMonthAndDay(
                                      widget._currentDate),
                                  startDateTime: widget._currentDate,
                                  pillToTake: pill));

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Pill Added!")),
                              );

                              FocusScope.of(context).unfocus();
                              Navigator.pop(context);
                            }
                          },
                          icon:
                              const Icon(Icons.check, color: Colors.lightGreen),
                          label: const Text(addPillFormConfirm)),
                      ElevatedButton.icon(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.clear, color: Colors.red),
                        label: const Text(addPillFormCancel),
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

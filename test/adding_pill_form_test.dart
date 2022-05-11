
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pill/bloc/pill_bloc.dart';
import 'package:pill/widget/adding_pill_form.dart';


void main() {
  testWidgets("Adding Pill Form - Add A Pill", (WidgetTester tester) async {

    await tester.pumpWidget(
      MultiBlocProvider(
    providers: [BlocProvider(
    create: (context) => PillBloc())],
        child: MaterialApp(
          home: AddingPillForm(DateTime.now())
        )
      )
    );

    await tester.ensureVisible(find.byType(AddingPillForm));

    await tester.enterText(find.byKey(ObjectKey("pillName")), "Test Pill");
    await tester.enterText(find.byKey(ObjectKey("pillRegiment")), "2");
    await tester.enterText(find.byKey(ObjectKey("pillDays")), "1");

    await tester.tap(find.byIcon(Icons.check));

    await tester.pumpAndSettle();

    expect(find.byType(AddingPillForm), findsNothing);

  });
}
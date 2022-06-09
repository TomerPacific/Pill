
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pill/bloc/pill_filter/pill_filter_bloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/widget/adding_pill_form.dart';


void main() {

  Widget base = MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (context) => PillBloc()
            ),
            BlocProvider(create: (context) =>
                PillFilterBloc(pillBloc: BlocProvider.of<PillBloc>(context))
            )
          ],
          child: MaterialApp(
              home: AddingPillForm(DateTime.now())
          )
      );

  testWidgets("Adding Pill Form - Add A Pill", (WidgetTester tester) async {

    await tester.pumpWidget(base);

    await tester.ensureVisible(find.byType(AddingPillForm));

    await tester.enterText(find.byKey(ObjectKey("pillName")), "Test Pill");
    await tester.enterText(find.byKey(ObjectKey("pillRegiment")), "2");
    await tester.enterText(find.byKey(ObjectKey("pillDays")), "1");

    await tester.tap(find.byIcon(Icons.check));

    await tester.pumpAndSettle();

    expect(find.byType(AddingPillForm), findsNothing);

  });

  testWidgets("Adding Pill Form - Trying to add a pill with an empty form", (WidgetTester tester) async {

    await tester.pumpWidget(base);

    await tester.ensureVisible(find.byType(AddingPillForm));

    await tester.tap(find.byIcon(Icons.check));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text("Please enter a pill name"), findsOneWidget);

  });

  testWidgets("Adding Pill Form - Trying to add a pill with only a pill name", (WidgetTester tester) async {

    await tester.pumpWidget(base);

    await tester.ensureVisible(find.byType(AddingPillForm));

    await tester.enterText(find.byKey(ObjectKey("pillName")), "Test Pill");

    await tester.tap(find.byIcon(Icons.check));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text("Please enter a pill name"), findsNothing);

    expect(find.text("Please enter a number representing the amount of pills to take"), findsOneWidget);

  });

  testWidgets("Adding Pill Form - Trying to add a pill without amount of days", (WidgetTester tester) async {

    await tester.pumpWidget(base);

    await tester.ensureVisible(find.byType(AddingPillForm));

    await tester.enterText(find.byKey(ObjectKey("pillName")), "Test Pill");

    await tester.enterText(find.byKey(ObjectKey("pillRegiment")), "2");

    await tester.tap(find.byIcon(Icons.check));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text("Please enter a pill name"), findsNothing);

    expect(find.text("Please enter a number representing the amount of pills to take"), findsNothing);

    expect(find.text("Please enter a number representing the number of days"), findsOneWidget);

  });

}
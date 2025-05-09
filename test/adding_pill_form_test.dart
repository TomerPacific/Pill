import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:pill/widget/adding_pill_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  DateService dateService = DateService();
  SharedPreferences.setMockInitialValues({});
  SharedPreferencesService sharedPreferencesService =
      await SharedPreferencesService.create(dateService);
  SharedPreferences.setMockInitialValues({});
  Widget base = MultiBlocProvider(providers: [
    BlocProvider(create: (context) => PillBloc(sharedPreferencesService)),
  ], child: MaterialApp(home: AddingPillForm(DateTime.now())));

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

  testWidgets("Adding Pill Form - Trying to add a pill with an empty form",
      (WidgetTester tester) async {
    await tester.pumpWidget(base);

    await tester.ensureVisible(find.byType(AddingPillForm));

    await tester.tap(find.byIcon(Icons.check));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text("Please enter a pill name"), findsOneWidget);
  });

  testWidgets("Adding Pill Form - Trying to add a pill with only a pill name",
      (WidgetTester tester) async {
    await tester.pumpWidget(base);

    await tester.ensureVisible(find.byType(AddingPillForm));

    await tester.enterText(find.byKey(ObjectKey("pillName")), "Test Pill");

    await tester.tap(find.byIcon(Icons.check));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text("Please enter a pill name"), findsNothing);

    expect(
        find.text(
            "Please enter a number representing the amount of pills to take"),
        findsOneWidget);
  });

  testWidgets("Adding Pill Form - Trying to add a pill without amount of days",
      (WidgetTester tester) async {
    await tester.pumpWidget(base);

    await tester.ensureVisible(find.byType(AddingPillForm));

    await tester.enterText(find.byKey(ObjectKey("pillName")), "Test Pill");

    await tester.enterText(find.byKey(ObjectKey("pillRegiment")), "2");

    await tester.tap(find.byIcon(Icons.check));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text("Please enter a pill name"), findsNothing);

    expect(
        find.text(
            "Please enter a number representing the amount of pills to take"),
        findsNothing);

    expect(find.text("Please enter a number representing the number of days"),
        findsOneWidget);
  });

  testWidgets("Adding Pill Form - Try to add pill with numbers as pill name",
      (WidgetTester tester) async {
    await tester.pumpWidget(base);

    await tester.ensureVisible(find.byType(AddingPillForm));

    await tester.enterText(find.byKey(ObjectKey("pillName")), "1234");

    await tester.tap(find.byIcon(Icons.check));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text("Please enter a pill name"), findsOneWidget);

    TextFormField pillName =
        tester.widget<TextFormField>(find.byKey(ObjectKey("pillName")));

    expect(pillName.controller?.text.length, 0);
  });
}

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
  
  Widget base = MultiBlocProvider(providers: [
    BlocProvider(create: (context) => PillBloc(sharedPreferencesService)),
  ], child: MaterialApp(home: Scaffold(body: AddingPillForm(DateTime.now()))));

  testWidgets("Adding Pill Form - Add A Pill with Defaults", (WidgetTester tester) async {
    await tester.pumpWidget(base);

    await tester.ensureVisible(find.byType(AddingPillForm));

    await tester.enterText(find.byKey(const ObjectKey("pillName")), "Test Pill");
    // Regiment and Days already have defaults (1 and 7)

    await tester.tap(find.byIcon(Icons.check));

    await tester.pumpAndSettle();

    // The form should be popped after success
    expect(find.byType(AddingPillForm), findsNothing);
  });

  testWidgets("Adding Pill Form - Trying to add a pill with an empty name",
      (WidgetTester tester) async {
    await tester.pumpWidget(base);

    await tester.ensureVisible(find.byType(AddingPillForm));
    
    // Clear the name field (it's empty by default anyway)
    await tester.enterText(find.byKey(const ObjectKey("pillName")), "");

    await tester.tap(find.byIcon(Icons.check));

    await tester.pumpAndSettle();

    expect(find.text("Please enter a pill name"), findsOneWidget);
  });

  testWidgets("Adding Pill Form - Add Pill with Instructions", (WidgetTester tester) async {
    await tester.pumpWidget(base);

    await tester.ensureVisible(find.byType(AddingPillForm));

    await tester.enterText(find.byKey(const ObjectKey("pillName")), "Test Pill");
    await tester.enterText(find.byKey(const ObjectKey("pillDescription")), "Take after eating");

    await tester.tap(find.byIcon(Icons.check));

    await tester.pumpAndSettle();

    expect(find.byType(AddingPillForm), findsNothing);
  });

  testWidgets("Adding Pill Form - Try to add pill with numbers as pill name",
      (WidgetTester tester) async {
    await tester.pumpWidget(base);

    await tester.ensureVisible(find.byType(AddingPillForm));

    // Input formatter should block numbers
    await tester.enterText(find.byKey(const ObjectKey("pillName")), "1234");

    await tester.tap(find.byIcon(Icons.check));

    await tester.pumpAndSettle();

    expect(find.text("Please enter a pill name"), findsOneWidget);

    TextFormField pillName =
        tester.widget<TextFormField>(find.byKey(const ObjectKey("pillName")));

    expect(pillName.controller?.text.length, 0);
  });
}

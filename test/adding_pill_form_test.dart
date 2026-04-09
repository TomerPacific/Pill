import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:pill/widget/adding_pill_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DateService dateService;
  late SharedPreferencesService sharedPreferencesService;
  final testDate = DateTime(2023, 1, 1);

  setUp(() async {
    dateService = DateService();
    SharedPreferences.setMockInitialValues({});
    sharedPreferencesService = await SharedPreferencesService.create(dateService);
  });

  Widget getBase() => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => PillBloc(sharedPreferencesService, dateService)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: AddingPillForm(
                pillDate: testDate,
                sharedPreferencesService: sharedPreferencesService,
                dateService: dateService),
          ),
        ),
      );

  testWidgets("Adding Pill Form - Add A Pill with Defaults", (WidgetTester tester) async {
    await tester.pumpWidget(getBase());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey("pillName")), "Test Pill");
    
    // We need to ensure the button is visible before tapping
    final applyButton = find.text("Apply");
    await tester.ensureVisible(applyButton);
    await tester.tap(applyButton);

    await tester.pumpAndSettle();

    // The form should be popped after success
    expect(find.byType(AddingPillForm), findsNothing);
  });

  testWidgets("Adding Pill Form - Trying to add a pill with an empty name", (WidgetTester tester) async {
    await tester.pumpWidget(getBase());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey("pillName")), "");

    final applyButton = find.text("Apply");
    await tester.ensureVisible(applyButton);
    await tester.tap(applyButton);

    await tester.pumpAndSettle();

    expect(find.text("Please enter a pill name"), findsOneWidget);
  });

  testWidgets("Adding Pill Form - Add Pill with Instructions", (WidgetTester tester) async {
    await tester.pumpWidget(getBase());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey("pillName")), "Test Pill");
    
    final descField = find.byKey(const ValueKey("pillDescription"));
    await tester.ensureVisible(descField);
    await tester.enterText(descField, "Take after eating");

    final applyButton = find.text("Apply");
    await tester.ensureVisible(applyButton);
    await tester.tap(applyButton);

    await tester.pumpAndSettle();

    expect(find.byType(AddingPillForm), findsNothing);
  });

  testWidgets("Adding Pill Form - Try to add pill with numbers as pill name", (WidgetTester tester) async {
    await tester.pumpWidget(getBase());
    await tester.pumpAndSettle();

    final pillNameField = find.byKey(const ValueKey("pillName"));
    // Input formatter should block numbers, resulting in an empty field
    await tester.enterText(pillNameField, "1234");

    final applyButton = find.text("Apply");
    await tester.ensureVisible(applyButton);
    await tester.tap(applyButton);

    await tester.pumpAndSettle();

    expect(find.text("Please enter a pill name"), findsOneWidget);

    final pillNameWidget = tester.widget<TextFormField>(pillNameField);
    expect(pillNameWidget.controller?.text.length, 0);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/constants.dart';
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

  Future<void> pumpForm(WidgetTester tester) async {
    await tester.pumpWidget(getBase());
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  testWidgets("Adding Pill Form - Add A Pill with Defaults", (WidgetTester tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byKey(const ValueKey("pillName")), "Test Pill");
    
    final applyButton = find.text("Apply");
    await tester.ensureVisible(applyButton);
    await tester.tap(applyButton);

    await tester.pumpAndSettle();

    expect(find.byType(AddingPillForm), findsNothing);
  });

  testWidgets("Adding Pill Form - Trying to add a pill with an empty name", (WidgetTester tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byKey(const ValueKey("pillName")), "");

    final applyButton = find.text("Apply");
    await tester.ensureVisible(applyButton);
    await tester.tap(applyButton);

    await tester.pumpAndSettle();

    expect(find.text("Please enter a pill name"), findsOneWidget);
  });

  testWidgets("Adding Pill Form - Increment pills per day to max cap", (WidgetTester tester) async {
    await pumpForm(tester);

    final incrementFinder = find.widgetWithIcon(IconButton, Icons.add_circle_outline);
    
    for (int i = 1; i < maxPillsPerDay; i++) {
      await tester.tap(incrementFinder);
      await tester.pump();
    }

    expect(find.text(maxPillsPerDay.toString()), findsOneWidget);

    final IconButton incrementButton = tester.widget(incrementFinder);
    expect(incrementButton.onPressed, isNull);
  });

  testWidgets("Adding Pill Form - Decrement pills per day to min cap", (WidgetTester tester) async {
    await pumpForm(tester);

    final decrementFinder = find.widgetWithIcon(IconButton, Icons.remove_circle_outline);
    
    expect(find.text("1"), findsOneWidget);

    final IconButton decrementButton = tester.widget(decrementFinder);
    expect(decrementButton.onPressed, isNull);
    
    await tester.tap(decrementFinder);
    await tester.pump();

    expect(find.text("1"), findsOneWidget);
  });
}

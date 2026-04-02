import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/constants.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:pill/widget/day_widget.dart';
import 'package:pill/widget/pill_to_take_widget.dart';
import 'package:pill/widget/pill_taken_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PillBloc pillBloc;
  late SharedPreferencesService sharedPreferencesService;
  final dateService = DateService();

  final testDate = DateTime(2023, 10, 10);
  final testDateStr = dateService.getDateAsMonthAndDay(testDate);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferencesService =
    await SharedPreferencesService.create(dateService);
    pillBloc = PillBloc(sharedPreferencesService);
  });

  tearDown(() async {
    await pillBloc.close();
  });

  /// Writes data to the service and waits for the bloc to process a loadPills
  /// event in a real async zone (tester.runAsync), so the bloc's state is
  /// fully updated BEFORE pumpWidget renders the widget tree.
  Future<void> seedBlocState(WidgetTester tester, void Function() serviceSetup) async {
    serviceSetup();
    await tester.runAsync(() async {
      pillBloc.add(PillsEvent(
        eventName: PillEvent.loadPills,
        date: testDateStr,
      ));
      // Wait for the bloc to emit the new state from the loadPills event
      await pillBloc.stream.first;
    });
  }

  Widget createWidgetUnderTest({required String header}) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            BlocProvider<PillBloc>.value(
              value: pillBloc,
              child: DayWidget(
                date: testDate,
                header: header,
                dateService: dateService,
              ),
            ),
          ],
        ),
      ),
    );
  }

  testWidgets(
      'DayWidget renders empty state and updates when a pill is added',
          (WidgetTester tester) async {
        // 1. Render the widget in its initial empty state
        await tester.pumpWidget(createWidgetUnderTest(header: pillsToTakeHeader));
        await tester.pumpAndSettle();

        expect(find.text(pillsToTakeHeader), findsOneWidget);
        expect(find.text(testDateStr), findsOneWidget);

        // 2. Write to service synchronously, then drive bloc state update via
        //    tester.runAsync so the stream emission fully completes
        const pill = PillToTake(
            pillName: "Test Pill", pillRegiment: 1, amountOfDaysToTake: 1);

        await seedBlocState(tester, () {
          sharedPreferencesService.addPillToDates(testDate, pill);
        });

        // 3. Pump the widget tree so BlocBuilder reacts to the already-emitted state
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(PillWidget), findsOneWidget);
        expect(find.text("Test Pill"), findsOneWidget);
        expect(find.text(pillsToTakeHeader), findsNothing);
      });

  testWidgets('DayWidget rebuilds correctly for pills taken list',
          (WidgetTester tester) async {
        // 1. Render the widget with the "Taken" header in empty state
        await tester.pumpWidget(createWidgetUnderTest(header: pillsTakenHeader));
        await tester.pumpAndSettle();

        expect(find.text(pillsTakenHeader), findsOneWidget);

        const pill = PillToTake(
            pillName: "Taken Pill", pillRegiment: 1, amountOfDaysToTake: 1);

        // 2. Add AND mark taken synchronously in the service, then drive bloc state
        await seedBlocState(tester, () {
          sharedPreferencesService.addPillToDates(testDate, pill);
          sharedPreferencesService.updatePillForDate(
              pill.copyWith(pillRegiment: 0, lastTaken: testDate), testDateStr);
        });

        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(PillTakenWidget), findsOneWidget);
        expect(find.text("Taken Pill"), findsOneWidget);
        expect(find.text(pillsTakenHeader), findsNothing);
      });

  testWidgets(
      'DayWidget does not throw ParentData exception when correctly placed in Column',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(header: pillsToTakeHeader));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        await seedBlocState(tester, () {
          sharedPreferencesService.addPillToDates(testDate,
              const PillToTake(
                  pillName: "Layout Pill", pillRegiment: 1, amountOfDaysToTake: 1));
        });

        await tester.pump();
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
}
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

// Freeze "now" so confirmDismiss never triggers the rollover path in tests.
class MockDateService extends DateService {
  final DateTime _now;
  MockDateService(this._now);
  @override
  DateTime now() => _now;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PillBloc pillBloc;
  late SharedPreferencesService sharedPreferencesService;
  late DateService dateService;

  final testDate = DateTime(2023, 10, 10);
  late String testDateStorageStr;
  late String testDateDisplayStr;

  setUp(() async {
    dateService = MockDateService(testDate);
    testDateStorageStr = dateService.formatDateForStorage(testDate);
    testDateDisplayStr = dateService.formatDateForDisplay(testDate);

    SharedPreferences.setMockInitialValues({});
    sharedPreferencesService =
    await SharedPreferencesService.create(dateService);
    pillBloc = PillBloc(sharedPreferencesService, dateService);
  });

  tearDown(() async {
    await pillBloc.close();
  });

  /// Writes data to the service and fires a loadPills event, waiting for the
  /// bloc to emit the new state before returning. Uses tester.runAsync so that
  /// real async (SharedPreferences) can complete inside the fake-async zone.
  Future<void> seedBlocState(
      WidgetTester tester, Future<void> Function() serviceSetup) async {
    await serviceSetup();
    await tester.runAsync(() async {
      pillBloc.add(PillsEvent(
        eventName: PillEvent.loadPills,
        date: testDateStorageStr,
      ));
      // Wait for the state that actually contains the loaded data (even if empty list).
      await pillBloc.stream.firstWhere((state) => state.pillsToTake != null);
    });
  }

  Widget createWidgetUnderTest({required DayWidgetMode mode}) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            BlocProvider<PillBloc>.value(
              value: pillBloc,
              child: DayWidget(
                date: testDate,
                mode: mode,
                dateService: dateService,
              ),
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('DayWidget renders empty state and updates when a pill is added',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(mode: DayWidgetMode.toTake));
        await tester.pumpAndSettle();

        expect(find.text(pillsToTakeHeader), findsOneWidget);
        expect(find.text(testDateDisplayStr), findsOneWidget);

        const pill = PillToTake(
            pillName: 'Test Pill', pillRegiment: 1, amountOfDaysToTake: 1);

        await seedBlocState(tester, () async {
          await sharedPreferencesService.addPillToDates(testDate, pill);
        });

        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(PillWidget), findsOneWidget);
        expect(find.text('Test Pill'), findsOneWidget);
        expect(find.text(pillsToTakeHeader), findsNothing);
      });

  testWidgets('DayWidget rebuilds correctly for pills taken list',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(mode: DayWidgetMode.taken));
        await tester.pumpAndSettle();

        expect(find.text(pillsTakenHeader), findsOneWidget);

        const pill = PillToTake(
            pillName: 'Taken Pill', pillRegiment: 1, amountOfDaysToTake: 1);

        await seedBlocState(tester, () async {
          await sharedPreferencesService.addPillToDates(testDate, pill);
          await sharedPreferencesService.updatePillForDate(
              pill.copyWith(pillRegiment: 0, lastTaken: testDate),
              testDateStorageStr);
        });

        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(PillTakenWidget), findsOneWidget);
        expect(find.text('Taken Pill'), findsOneWidget);
        expect(find.text(pillsTakenHeader), findsNothing);
      });

  testWidgets(
      'DayWidget does not throw ParentData exception when correctly placed in Column',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(mode: DayWidgetMode.toTake));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        await seedBlocState(tester, () async {
          await sharedPreferencesService.addPillToDates(
              testDate,
              const PillToTake(
                  pillName: 'Layout Pill', pillRegiment: 1, amountOfDaysToTake: 1));
        });

        await tester.pump();
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

  testWidgets('DayWidget dismisses pill, shows SnackBar, and undos',
          (WidgetTester tester) async {
        const pill = PillToTake(
            pillName: 'Dismiss Pill', pillRegiment: 1, amountOfDaysToTake: 1);

        await seedBlocState(tester, () async {
          await sharedPreferencesService.addPillToDates(testDate, pill);
        });

        await tester.pumpWidget(createWidgetUnderTest(mode: DayWidgetMode.toTake));
        await tester.pumpAndSettle();

        expect(find.byType(PillWidget), findsOneWidget);

        // Swipe end-to-start (right to left) to dismiss.
        await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
        await tester.pumpAndSettle();

        expect(find.byType(PillWidget), findsNothing);
        expect(find.text('Dismiss Pill removed'), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);

        // Subscribe before tapping so we cannot miss the emission.
        final stateAfterUndo = pillBloc.stream.firstWhere(
              (state) =>
          state.pillsToTake?.any((p) => p.pillName == 'Dismiss Pill') ?? false,
        );

        await tester.tap(find.text('Undo'));
        await tester.runAsync(() => stateAfterUndo);

        // Poll until the BlocConsumer listener's setState propagates.
        for (int i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 100));
          if (find.byType(PillWidget).evaluate().length == 1) break;
        }

        expect(find.byType(PillWidget), findsOneWidget);
        expect(find.text('Dismiss Pill'), findsOneWidget);
      });

  testWidgets('DayWidget dismisses one of multiple pills and undos correctly',
          (WidgetTester tester) async {
        // Increase surface size to ensure all 3 pills are rendered by ListView.builder
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());
        addTearDown(() => tester.view.resetDevicePixelRatio());

        const pill1 =
        PillToTake(pillName: 'Pill 1', pillRegiment: 1, amountOfDaysToTake: 1);
        const pill2 =
        PillToTake(pillName: 'Pill 2', pillRegiment: 1, amountOfDaysToTake: 1);
        const pill3 =
        PillToTake(pillName: 'Pill 3', pillRegiment: 1, amountOfDaysToTake: 1);

        await seedBlocState(tester, () async {
          await sharedPreferencesService.addPillToDates(testDate, pill1);
          await sharedPreferencesService.addPillToDates(testDate, pill2);
          await sharedPreferencesService.addPillToDates(testDate, pill3);
        });

        await tester.pumpWidget(createWidgetUnderTest(mode: DayWidgetMode.toTake));
        await tester.pumpAndSettle();

        expect(find.byType(PillWidget), findsNWidgets(3));

        // Swipe Pill 2 to dismiss.
        final pill2Dismissible = find.ancestor(
          of: find.text('Pill 2'),
          matching: find.byType(Dismissible),
        );
        await tester.drag(pill2Dismissible, const Offset(-500, 0));
        await tester.pumpAndSettle();

        expect(find.text('Pill 2'), findsNothing);
        expect(find.text('Pill 1'), findsOneWidget);
        expect(find.text('Pill 3'), findsOneWidget);
        expect(find.byType(PillWidget), findsNWidgets(2));
        expect(find.text('Pill 2 removed'), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);

        // Wait for a state that has all 3 pills back.
        final stateAfterUndo = pillBloc.stream.firstWhere(
              (state) => (state.pillsToTake?.length ?? 0) >= 3,
        );

        await tester.tap(find.text('Undo'));
        await tester.runAsync(() => stateAfterUndo);

        for (int i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 100));
          if (find.byType(PillWidget).evaluate().length == 3) break;
        }

        await tester.pumpAndSettle();

        expect(find.text('Pill 1'), findsOneWidget);
        expect(find.text('Pill 2'), findsOneWidget);
        expect(find.text('Pill 3'), findsOneWidget);
        expect(find.byType(PillWidget), findsNWidgets(3));
      });

  testWidgets('DayWidget swipe start-to-end does NOT dismiss',
          (WidgetTester tester) async {
        const pill = PillToTake(
            pillName: 'No Dismiss Pill', pillRegiment: 1, amountOfDaysToTake: 1);

        await seedBlocState(tester, () async {
          await sharedPreferencesService.addPillToDates(testDate, pill);
        });

        await tester.pumpWidget(createWidgetUnderTest(mode: DayWidgetMode.toTake));
        await tester.pumpAndSettle();

        expect(find.byType(PillWidget), findsOneWidget);

        // Swipe start-to-end (left to right) — should bounce back, not dismiss.
        await tester.drag(find.byType(Dismissible), const Offset(500, 0));
        await tester.pumpAndSettle();

        expect(find.byType(PillWidget), findsOneWidget);
        expect(find.text('No Dismiss Pill'), findsOneWidget);
        expect(find.text('No Dismiss Pill removed'), findsNothing);
      });
}
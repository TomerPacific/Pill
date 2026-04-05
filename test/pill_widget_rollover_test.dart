import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:pill/widget/pill_to_take_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockDateService extends DateService {
  DateTime _now;
  MockDateService(this._now);

  @override
  DateTime now() => _now;

  void setNow(DateTime newNow) {
    _now = newNow;
  }
}

class MockPillBloc extends PillBloc {
  final List<PillsEvent> capturedEvents = [];

  MockPillBloc(super.sharedPreferencesService, super.dateService);

  @override
  void add(PillsEvent event) {
    capturedEvents.add(event);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockDateService dateService;
  late MockPillBloc mockPillBloc;
  late SharedPreferencesService sharedPreferencesService;
  final DateTime widgetDate = DateTime(2023, 1, 1);

  setUp(() async {
    dateService = MockDateService(widgetDate);
    SharedPreferences.setMockInitialValues({});
    sharedPreferencesService = await SharedPreferencesService.create(dateService);
    mockPillBloc = MockPillBloc(sharedPreferencesService, dateService);
  });

  Widget getBase() => BlocProvider<PillBloc>.value(
        value: mockPillBloc,
        child: MaterialApp(
          home: Scaffold(
            body: PillWidget(
              pillToTake: const PillToTake(
                  pillName: "Test Pill",
                  pillRegiment: 1,
                  amountOfDaysToTake: 1),
              dateService: dateService,
              date: widgetDate,
            ),
          ),
        ),
      );

  testWidgets("PillWidget - Rollover: Tapping on a stale day triggers loadPills",
      (WidgetTester tester) async {
    // 1. Setup: Current time is a different day (rollover)
    final tomorrow = widgetDate.add(const Duration(days: 1));
    dateService.setNow(tomorrow);

    await tester.pumpWidget(getBase());
    await tester.pumpAndSettle();

    // 2. Action: Tap the pill widget
    await tester.tap(find.byType(PillWidget));
    await tester.pumpAndSettle();

    // 3. Assertion: Verify loadPills was dispatched, NOT updatePill
    final loadPillsEvents = mockPillBloc.capturedEvents
        .where((e) => e.eventName == PillEvent.loadPills)
        .toList();
    final updatePillEvents = mockPillBloc.capturedEvents
        .where((e) => e.eventName == PillEvent.updatePill)
        .toList();

    expect(loadPillsEvents.length, 1);
    expect(loadPillsEvents.first.date, dateService.formatDateForStorage(tomorrow));
    expect(updatePillEvents.isEmpty, true);
  });

  testWidgets("PillWidget - No Rollover: Tapping on current day triggers updatePill",
      (WidgetTester tester) async {
    // 1. Setup: Current time is the same day
    dateService.setNow(widgetDate);

    await tester.pumpWidget(getBase());
    await tester.pumpAndSettle();

    // 2. Action: Tap the pill widget
    await tester.tap(find.byType(PillWidget));
    await tester.pumpAndSettle();

    // 3. Assertion: Verify updatePill was dispatched
    final loadPillsEvents = mockPillBloc.capturedEvents
        .where((e) => e.eventName == PillEvent.loadPills)
        .toList();
    final updatePillEvents = mockPillBloc.capturedEvents
        .where((e) => e.eventName == PillEvent.updatePill)
        .toList();

    expect(updatePillEvents.length, 1);
    expect(updatePillEvents.first.date, dateService.formatDateForStorage(widgetDate));
    expect(loadPillsEvents.isEmpty, true);
  });
}

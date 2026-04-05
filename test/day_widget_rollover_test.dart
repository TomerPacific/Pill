import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/bloc/pill/pill_state.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:pill/widget/day_widget.dart';
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

  MockPillBloc(super.sharedPreferencesService, super.dateService, {PillState? initialState})
      : _initialState = initialState ?? PillState();

  final PillState _initialState;

  @override
  PillState get state => _initialState;

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
  const testPill = PillToTake(
      pillName: "Test Pill",
      pillRegiment: 1,
      amountOfDaysToTake: 1);

  setUp(() async {
    dateService = MockDateService(widgetDate);
    SharedPreferences.setMockInitialValues({});
    sharedPreferencesService = await SharedPreferencesService.create(dateService);
    mockPillBloc = MockPillBloc(sharedPreferencesService, dateService, 
        initialState: PillState(pillsToTake: const [testPill]));
  });

  Widget getBase() => BlocProvider<PillBloc>.value(
        value: mockPillBloc,
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                DayWidget(
                  date: widgetDate,
                  mode: DayWidgetMode.toTake,
                  dateService: dateService,
                ),
              ],
            ),
          ),
        ),
      );

  testWidgets("DayWidget - Rollover in onDismissed: Tapping on a stale day triggers loadPills",
      (WidgetTester tester) async {
    // 1. Setup: Current time is a different day (rollover)
    final tomorrow = widgetDate.add(const Duration(days: 1));
    dateService.setNow(tomorrow);

    await tester.pumpWidget(getBase());
    await tester.pumpAndSettle();

    // 2. Action: Dismiss the pill (swipe left)
    await tester.drag(find.byType(Dismissible), const Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    // 3. Assertion: Verify loadPills was dispatched, NOT removePill
    final loadPillsEvents = mockPillBloc.capturedEvents
        .where((e) => e.eventName == PillEvent.loadPills)
        .toList();
    final removePillEvents = mockPillBloc.capturedEvents
        .where((e) => e.eventName == PillEvent.removePill)
        .toList();

    expect(loadPillsEvents.length, 1);
    expect(loadPillsEvents.first.date, dateService.formatDateForStorage(tomorrow));
    expect(removePillEvents.isEmpty, true);
  });

  testWidgets("DayWidget - No Rollover in onDismissed: Tapping on current day triggers removePill",
      (WidgetTester tester) async {
    // 1. Setup: Current time is the same day
    dateService.setNow(widgetDate);

    await tester.pumpWidget(getBase());
    await tester.pumpAndSettle();

    // 2. Action: Dismiss the pill (swipe left)
    await tester.drag(find.byType(Dismissible), const Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    // 3. Assertion: Verify removePill was dispatched
    final loadPillsEvents = mockPillBloc.capturedEvents
        .where((e) => e.eventName == PillEvent.loadPills)
        .toList();
    final removePillEvents = mockPillBloc.capturedEvents
        .where((e) => e.eventName == PillEvent.removePill)
        .toList();

    expect(removePillEvents.length, 1);
    expect(removePillEvents.first.date, dateService.formatDateForStorage(widgetDate));
    expect(loadPillsEvents.isEmpty, true);
  });
}

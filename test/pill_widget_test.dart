import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pill/bloc/clearPills/ClearPillsBloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/bloc/pill/pill_state.dart';
import 'package:pill/bloc/theme/theme_block.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:pill/widget/pill_taken_widget.dart';
import 'package:pill/widget/pill_to_take_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  DateService dateService = DateService();
  SharedPreferences.setMockInitialValues({});
  SharedPreferencesService sharedPreferencesService =
      await SharedPreferencesService.create(dateService);
  String currentDate = dateService.getDateAsMonthAndDay(DateTime.now());
  String title = "You do not have to take any pills today 😀";

  setUp(() async {
    sharedPreferencesService.clearAllPillsFromDate(DateTime.now());
  });

  Widget base = MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => PillBloc(sharedPreferencesService)
              ..add(PillsEvent(
                  eventName: PillEvent.loadPills, date: currentDate))),
        BlocProvider(
            create: (context) => ThemeBloc(sharedPreferencesService, false)),
        BlocProvider(
            create: (context) => ClearPillsBloc(sharedPreferencesService)),
      ],
      child: MaterialApp(home: BlocBuilder<PillBloc, PillState>(
        builder: (context, state) {
          return Container(
              child: SizedBox(
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Text(currentDate,
                        style: TextStyle(
                            fontSize: 25.0, fontWeight: FontWeight.bold)),
                  ),
                ),
                (title == "You do not have to take any pills today 😀")
                    ? (state.pillsToTake == null || state.pillsToTake!.isEmpty)
                        ? Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(title,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)))
                        : Expanded(
                            child: SizedBox(
                            height: 200.0,
                            child: ListView.builder(
                                itemCount: state.pillsToTake!.length,
                                itemBuilder: (_, index) => Dismissible(
                                    key: ObjectKey(
                                        state.pillsToTake![index].pillName),
                                    child: PillWidget(
                                      pillToTake: state.pillsToTake![index],
                                      dateService: dateService,
                                    ),
                                    onDismissed: (direction) {
                                      context.read<PillBloc>().add(PillsEvent(
                                          eventName: PillEvent.removePill,
                                          date: currentDate,
                                          pillToTake: state.pillsToTake![index],
                                          pillsToTake: state.pillsToTake,
                                          pillsTaken: state.pillsTaken));
                                    })),
                          ))
                    : (state.pillsTaken == null || state.pillsTaken!.isEmpty)
                        ? Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(title,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)))
                        : Expanded(
                            child: SizedBox(
                                height: 200.0,
                                child: ListView.builder(
                                  itemCount: state.pillsTaken!.length,
                                  itemBuilder: (_, index) => PillTakenWidget(
                                      pillToTake: state.pillsTaken![index],
                                      dateService: dateService),
                                )),
                          )
              ],
            ),
          ));
        },
      )));

  testWidgets("Pill Widget", (WidgetTester tester) async {
    PillToTake pillToTake = PillToTake(
        pillRegiment: 1, pillName: "Test Pill", amountOfDaysToTake: 1);

    await tester.pumpWidget(base);

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    BuildContext context = tester.element(find.byType(Container));

    context.read<PillBloc>().add(PillsEvent(
        eventName: PillEvent.addPill,
        date: currentDate,
        pillToTake: pillToTake));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    await tester.ensureVisible(find.byType(PillWidget));

    await tester.tap(find.byType(PillWidget));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Test Pill'), findsNothing);
  });

  testWidgets("PillWidget Dismiss Pill", (WidgetTester tester) async {
    PillToTake pillToTake = PillToTake(
        pillRegiment: 1, pillName: "Test Pill", amountOfDaysToTake: 1);

    await tester.pumpWidget(base);

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    BuildContext context = tester.element(find.byType(Container));

    context.read<PillBloc>().add(PillsEvent(
        eventName: PillEvent.addPill,
        date: currentDate,
        pillToTake: pillToTake));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    await tester.ensureVisible(find.byType(PillWidget));

    await tester.drag(find.byType(Dismissible), const Offset(500.0, 0.0));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Test Pill'), findsNothing);
  });

  testWidgets("PillWidget Take Pill And See Last Time Taken",
      (WidgetTester tester) async {
    PillToTake pillToTake = PillToTake(
        pillRegiment: 2, pillName: "Test Pill", amountOfDaysToTake: 1);

    await tester.pumpWidget(base);

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    BuildContext context = tester.element(find.byType(Container));

    context.read<PillBloc>().add(PillsEvent(
        eventName: PillEvent.addPill,
        date: currentDate,
        pillToTake: pillToTake));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    await tester.ensureVisible(find.byType(PillWidget));

    await tester.tap(find.byType(PillWidget));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.access_time), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pill/bloc/clearPills/clear_pills_bloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/bloc/pill/pill_state.dart';
import 'package:pill/bloc/theme/theme_block.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
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
    sharedPreferencesService.clearAllPills();
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
          return Scaffold(
              body: SizedBox(
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
                        style: const TextStyle(
                            fontSize: 25.0, fontWeight: FontWeight.bold)),
                  ),
                ),
                (state.pillsToTake == null || state.pillsToTake!.isEmpty)
                    ? Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(title,
                            style: const TextStyle(
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
              ],
            ),
          ));
        },
      )));

  testWidgets("Pill Widget - Info Icon Display and Tooltip", (WidgetTester tester) async {
    PillToTake pillWithInfo = PillToTake(
        pillRegiment: 1, 
        pillName: "Info Pill", 
        amountOfDaysToTake: 1,
        description: "Take with water");

    await tester.pumpWidget(base);
    await tester.pumpAndSettle();

    BuildContext context = tester.element(find.byType(Scaffold));
    context.read<PillBloc>().add(PillsEvent(
        eventName: PillEvent.addPill,
        date: currentDate,
        pillToTake: pillWithInfo));

    await tester.pumpAndSettle();

    // Verify Info Icon is visible
    expect(find.byIcon(Icons.info_outline), findsOneWidget);

    // Verify the Tooltip widget itself exists with the correct message
    final tooltipFinder = find.byType(Tooltip);
    expect(tooltipFinder, findsOneWidget);
    final Tooltip tooltip = tester.widget(tooltipFinder);
    expect(tooltip.message, "Take with water");
    
    // To actually test the visibility of the text after tap:
    await tester.tap(find.byIcon(Icons.info_outline));
    // We need to pump enough for the tooltip to start appearing
    await tester.pump(const Duration(milliseconds: 500)); 
    
    // Look for the text in the Tooltip's overlay
    expect(find.text("Take with water"), findsOneWidget);
  });

  testWidgets("Pill Widget - Event Isolation (Info tap doesn't take pill)", (WidgetTester tester) async {
    PillToTake pillWithInfo = PillToTake(
        pillRegiment: 1, 
        pillName: "Safe Pill", 
        amountOfDaysToTake: 1,
        description: "Don't trigger take");

    await tester.pumpWidget(base);
    await tester.pumpAndSettle();

    BuildContext context = tester.element(find.byType(Scaffold));
    context.read<PillBloc>().add(PillsEvent(
        eventName: PillEvent.addPill,
        date: currentDate,
        pillToTake: pillWithInfo));

    await tester.pumpAndSettle();

    // Tap Info Icon
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();

    // If the pill was taken, it would be removed from the list (regiment 1 -> 0)
    expect(find.text('Safe Pill'), findsOneWidget);
  });

  testWidgets("Pill Widget - Taking a Pill", (WidgetTester tester) async {
    PillToTake pillToTake = PillToTake(
        pillRegiment: 1, pillName: "Action Pill", amountOfDaysToTake: 1);

    await tester.pumpWidget(base);
    await tester.pumpAndSettle();

    BuildContext context = tester.element(find.byType(Scaffold));
    context.read<PillBloc>().add(PillsEvent(
        eventName: PillEvent.addPill,
        date: currentDate,
        pillToTake: pillToTake));

    await tester.pumpAndSettle();

    // Tap the card (not the info icon)
    // Avoid tapping the top-right corner where the info icon might be (though not here)
    await tester.tap(find.text('Action Pill')); 
    await tester.pumpAndSettle();

    // Pill should be gone as regiment is 0
    expect(find.text('Action Pill'), findsNothing);
  });
}

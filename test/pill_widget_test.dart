
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/bloc/pill/pill_event.dart';
import 'package:pill/bloc/pill/pill_state.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:pill/widget/pill_to_take_widget.dart';

void main() {


  String currentDate = DateService().getDateAsMonthAndDay(DateTime.now());

  setUp(() async {
    await SharedPreferencesService().init();
    SharedPreferencesService().clearAllPillsFromDate(currentDate);
  });

  Widget drawPills(BuildContext context, PillState state) {
    if (state is PillLoading) {
      return const CircularProgressIndicator();
    }
    if (state is PillLoaded) {
      return state.pillsToTake.length == 0 ?
      new Padding(
          padding: const EdgeInsets.only(top: 20),
          child: new Text(
              "You do not have to take any pills today 😀",
              style: new TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
          )
      )
          :
      Expanded(
          child: SizedBox(
            height: 200.0,
            child:  ListView.builder(
                itemCount: state.pillsToTake.length,
                itemBuilder:
                    (_, index) =>
                new Dismissible(
                    key: ObjectKey(state.pillsToTake[index].pillName),
                    child: new PillWidget(pillToTake: state.pillsToTake[index]),
                    onDismissed: (direction) {
                      context.read<PillBloc>().add(DeletePill(pillToTake: state.pillsToTake[index]));
                      //state.pillsToTake.removeAt(index);
                    }
                )
            ),
          )
      );
    }
    else {
      return const Text("Something went wrong");
    }
  }

  Widget base = MultiBlocProvider(
      providers: [BlocProvider(
        create: (context) => PillBloc()..add(LoadPill()),)],
      child: MaterialApp(
          home: BlocBuilder<PillBloc, PillState>(
              builder: (context, state) {
                return new Container(
                    child:new SizedBox(
                        height: double.infinity,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              new Align(
                                alignment: Alignment.topCenter,
                                child:  new Padding(
                                  padding: const EdgeInsets.only(
                                      top:40.0
                                  ),
                                  child: new Text(
                                      currentDate,
                                      style: new TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold)
                                  ),
                                ),
                              ),
                              drawPills(context, state)
                            ]
                        )
                    )
                );
              }
          )
      )
  );


  testWidgets("PillWidget Click On Pill", (WidgetTester tester) async {
    PillToTake pillToTake = new PillToTake(
        pillRegiment: 1,
        pillName: "Test Pill",
        amountOfDaysToTake: 1);

    await tester.pumpWidget(base);

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    BuildContext context = tester.element(find.byType(Container));

    context.read<PillBloc>().add(AddPill(pillToTake: pillToTake));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    await tester.ensureVisible(find.byType(PillWidget));

    await tester.tap(find.byType(PillWidget));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Test Pill'), findsNothing);
  });

  testWidgets("PillWidget Dismiss Pill", (WidgetTester tester) async {
    PillToTake pillToTake = new PillToTake(
        pillRegiment: 1,
        pillName: "Test Pill",
        amountOfDaysToTake: 1);

    await tester.pumpWidget(base);

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    BuildContext context = tester.element(find.byType(Container));

    context.read<PillBloc>().add(AddPill(pillToTake: pillToTake));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    await tester.ensureVisible(find.byType(PillWidget));

    await tester.drag(find.byType(Dismissible), const Offset(500.0, 0.0));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Test Pill'), findsNothing);
  });

  testWidgets("PillWidget Take Pill And See Last Time Taken", (WidgetTester tester) async {
    PillToTake pillToTake = new PillToTake(
        pillRegiment: 2,
        pillName: "Test Pill",
        amountOfDaysToTake: 1);

    await tester.pumpWidget(base);

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    BuildContext context = tester.element(find.byType(Container));

    context.read<PillBloc>().add(AddPill(pillToTake: pillToTake));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    await tester.ensureVisible(find.byType(PillWidget));

    await tester.tap(find.byType(PillWidget));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.access_time), findsOneWidget);
  });

}
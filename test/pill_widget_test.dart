import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/bloc/pill/pill_event.dart';
import 'package:pill/bloc/pill_filter/pill_filter_bloc.dart';
import 'package:pill/bloc/pill_filter/pill_filter_state.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/service/shared_preferences_service.dart';
import 'package:pill/widget/pill_taken_widget.dart';
import 'package:pill/widget/pill_to_take_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {

  String currentDate = DateService().getDateAsMonthAndDay(DateTime.now());
  SharedPreferencesService sharedPreferencesService = new SharedPreferencesService();

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    sharedPreferencesService.clearAllPillsFromDate(DateTime.now());
  });

  Widget _buildPillList(BuildContext context, List<dynamic> pills) {
    if (pills is List<PillToTake> && pills.length > 0) {
      return Expanded(
          child: SizedBox(
            height: 200.0,
            child:  ListView.builder(
                itemCount: pills.length,
                itemBuilder:
                    (_, index) =>
                new Dismissible(
                    key: ObjectKey(pills[index].pillName),
                    child: new PillWidget(pillToTake: pills[index]),
                    onDismissed: (direction) {
                      context.read<PillBloc>().add(DeletePill(pillToTake: pills[index]));
                      //state.pillsToTake.removeAt(index);
                    }
                )
            ),
          )
      );
    } else if (pills is List<PillTaken> && pills.length > 0) {
      return Expanded(
        child: SizedBox(
            height: 200.0,
            child:  ListView.builder(
              itemCount: pills.length,
              itemBuilder:
                  (_, index) =>
              new PillTakenWidget(pillToTake: pills[index]),
            )
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget drawPills(BuildContext context, PillFilterState state) {
    if (state is PillFilterLoading) {
      return const CircularProgressIndicator();
    }
    if (state is PillFilterLoaded) {
      List<dynamic> pills = state.filteredPills;
      return pills.length == 0 ?
      new Padding(
          padding: const EdgeInsets.only(top: 20),
          child: new Text(
              "title",
              style: new TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
          )
      )
          :
      _buildPillList(context, pills);
    }
    else {
      return const Text("Something went wrong");
    }
  }

  Widget base = MultiBlocProvider(
      providers: [BlocProvider(
        create: (context) => PillBloc()..add(LoadPill()),),
        BlocProvider(create: (context) => PillFilterBloc(pillBloc: BlocProvider.of<PillBloc>(context)))
      ],
      child: MaterialApp(
          home: BlocBuilder<PillFilterBloc, PillFilterState>(
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


  testWidgets("Pill Widget", (WidgetTester tester) async {
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
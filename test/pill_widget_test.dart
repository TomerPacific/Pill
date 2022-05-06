import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pill/model/pill_to_take.dart';

void main() {

  testWidgets("PillWidget Dismiss Pill", (WidgetTester tester) async {
    PillToTake pillToTake = new PillToTake();

    await tester.pumpWidget(
        MaterialApp(
            home: Material(
                child: new Container(
                  child: new Dismissible(
                    key: ObjectKey(pillToTake.pillName),
                    child:new Card(
                    child: InkWell(
                        splashColor: Colors.blue.withAlpha(30),
                        onTap: () {

                        },
                        child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    new Text(
                                      pillToTake.pillName,
                                      style: new TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold
                                      ),
                                    )
                                  ]
                              ),
                              new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                      pillToTake.pillImage,
                                      width: 100,
                                      height: 100
                                  )
                                ],
                              ),
                              new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  new Text(
                                      "Pills left to take today: ${pillToTake
                                          .pillRegiment}",
                                      style: new TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold
                                      )
                                  )
                                ],
                              )
                            ]
                        )
                    ),
                  ),
                  )
                )
            )
        )
    );

    await tester.drag(find.byType(Dismissible), const Offset(500.0, 0.0));
    await tester.pumpAndSettle();
    expect(find.text('Random Pill'), findsNothing);
  });
}
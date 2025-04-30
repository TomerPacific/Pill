import 'package:flutter/material.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/utils.dart';

const double PILL_IMAGE_WIDTH = 100.0;
const double PILL_IMAGE_HEIGHT = 100.0;

class PillTakenWidget extends StatelessWidget {
  const PillTakenWidget({required this.pillToTake, required this.dateService})
      : super();

  final PillTaken pillToTake;
  final DateService dateService;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  pillToTake.pillName,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                )
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(pillToTake.pillImage,
                      width: PILL_IMAGE_WIDTH,
                      height: PILL_IMAGE_HEIGHT,
                      color: Utils.getPillTakenImageColor(context))
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.access_time),
                Text(dateService.getHourFromDate(pillToTake.lastTaken!),
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold))
              ])
            ])),
      ),
    );
  }
}

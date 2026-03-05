import 'package:flutter/material.dart';
import 'package:pill/constants.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/service/date_service.dart';

class PillTakenWidget extends StatelessWidget {
  const PillTakenWidget({required this.pillTaken, required this.dateService})
      : super();

  final PillTaken pillTaken;
  final DateService dateService;

  @override
  Widget build(BuildContext context) {
    DateTime? lastTaken = pillTaken.lastTaken;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pillTaken.pillName,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Center(
                child: FractionallySizedBox(
                    widthFactor:IMAGE_WIDTH_FACTOR,
                    child: Image.asset(
                      pillTaken.pillImage,
                      fit: BoxFit.contain,
                      semanticLabel: pillTaken.pillName,
                    ))),
            if (lastTaken != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time),
                  SizedBox(width: 5),
                  Text(
                    "Last taken today at: ${dateService.getHourFromDate(lastTaken)}",
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

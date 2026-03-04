import 'package:flutter/material.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/service/date_service.dart';

class PillTakenWidget extends StatelessWidget {
  const PillTakenWidget({required this.pillToTake, required this.dateService})
      : super();

  final PillTaken pillToTake;
  final DateService dateService;

  @override
  Widget build(BuildContext context) {
    DateTime? lastTaken = pillToTake.lastTaken;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pillToTake.pillName,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
             Image.asset(
                pillToTake.pillImage,
                height: 250,
                fit: BoxFit.contain,
              ),
            if (lastTaken != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time),
                  SizedBox(width: 5),
                  Text(
                    "Last taken today at : ${dateService.getHourFromDate(lastTaken)}",
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

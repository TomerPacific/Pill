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

    return SizedBox(
      height: 280,
      child: Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                pillToTake.pillName,
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Image.asset(
                    pillToTake.pillImage,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),
              if (lastTaken != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time, size: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Text(
                        "Last taken today at : ${dateService.getHourFromDate(lastTaken)}",
                        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

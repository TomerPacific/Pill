import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/constants.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';

class PillWidget extends StatelessWidget {
  const PillWidget({required this.pillToTake, required this.dateService})
      : super();

  final PillToTake pillToTake;
  final DateService dateService;

  void _handleOnTap(BuildContext context) {
    if (pillToTake.pillRegiment > 0) {
      PillToTake updatedPillToTake = pillToTake.copyWith(
          pillRegiment: pillToTake.pillRegiment - 1, lastTaken: DateTime.now());
      context.read<PillBloc>().add(PillsEvent(
          eventName: PillEvent.updatePill,
          date: dateService.getCurrentDateAsMonthAndDay(),
          pillToTake: updatedPillToTake));
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime? lastTaken = pillToTake.lastTaken;
    bool hasDescription =
        pillToTake.description != null && pillToTake.description!.isNotEmpty;

    return Container(
      child: Card(
        child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              _handleOnTap(context);
            },
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  pillToTake.pillName,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                )
              ]),
              Center(
                child: FractionallySizedBox(
                    widthFactor: PILL_IMAGE_WIDTH_FACTOR,
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(pillToTake.pillImage,
                              fit: BoxFit.contain,
                              semanticLabel: pillToTake.pillName),
                        ),
                        if (hasDescription)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                // This empty callback prevents the tap from
                                // bubbling up to the InkWell/Card.
                                // The Tooltip still triggers on tap.
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Tooltip(
                                message: pillToTake.description!,
                                triggerMode: TooltipTriggerMode.tap,
                                showDuration: const Duration(seconds: 5),
                                child: Container(
                                  padding: const EdgeInsets.all(12), // Larger hit area
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.info_outline,
                                    color: Colors.orange,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Pills left to take today: ${pillToTake.pillRegiment}",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold))
                ],
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: lastTaken != null
                      ? [
                          Icon(Icons.access_time),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                              child: Text(
                                  "Last taken today at: ${dateService.getHourFromDate(lastTaken)}",
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold)))
                        ]
                      : [])
            ])),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/constants.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';

class PillWidget extends StatelessWidget {
  const PillWidget(
      {super.key, required this.pillToTake, required this.dateService});

  final PillToTake pillToTake;
  final DateService dateService;

  void _handleOnTap(BuildContext context) {
    if (pillToTake.pillRegiment > 0) {
      final now = DateTime.now();
      PillToTake updatedPillToTake = pillToTake.copyWith(
          pillRegiment: pillToTake.pillRegiment - 1, lastTaken: now);
      context.read<PillBloc>().add(PillsEvent(
          eventName: PillEvent.updatePill,
          date: dateService.formatDateForStorage(now),
          pillToTake: updatedPillToTake));
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime? lastTaken = pillToTake.lastTaken;
    bool hasDescription =
        pillToTake.description != null && pillToTake.description!.isNotEmpty;

    return Card(
      child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            _handleOnTap(context);
          },
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                pillToTake.pillName,
                style:
                    const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              )
            ]),
            Center(
              child: FractionallySizedBox(
                  widthFactor: pillImageWidthFactor,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 100),
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
                            child: Tooltip(
                              message: pillToTake.description!,
                              triggerMode: TooltipTriggerMode.tap,
                              waitDuration: Duration.zero,
                              showDuration: const Duration(seconds: 3),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(230),
                                  shape: BoxShape.circle,
                                  boxShadow: const [
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
                      ],
                    ),
                  )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Pills left to take today: ${pillToTake.pillRegiment}",
                    style: const TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.bold))
              ],
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: lastTaken != null
                    ? [
                        const Icon(Icons.access_time),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                            child: Text(
                                "Last taken today at: ${dateService.getHourFromDate(lastTaken)}",
                                style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold)))
                      ]
                    : [])
          ])),
    );
  }
}

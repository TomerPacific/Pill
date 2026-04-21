import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/pill/pill_bloc.dart';
import 'package:pill/bloc/pill/pill_state.dart';
import 'package:pill/constants.dart';
import 'package:pill/model/pill_taken.dart';
import 'package:pill/model/pill_to_take.dart';
import 'package:pill/service/date_service.dart';
import 'package:pill/widget/pill_taken_widget.dart';
import 'package:pill/widget/pill_to_take_widget.dart';

enum DayWidgetMode { toTake, taken }

class DayWidget extends StatefulWidget {
  const DayWidget(
      {super.key,
        required this.date,
        required this.mode,
        required this.dateService});

  final DateTime date;
  final DayWidgetMode mode;
  final DateService dateService;

  @override
  State<DayWidget> createState() => _DayWidgetState();
}

class _DayWidgetState extends State<DayWidget> {
  // Local copy of the pill list, kept in sync with bloc via BlocConsumer.
  // Mutated immediately on dismiss so Dismissible is satisfied synchronously.
  List<PillToTake>? _localPills;

  // Track names of pills dismissed locally but not yet confirmed removed by
  // the bloc, so we don't re-introduce them prematurely from a stale emission.
  final Set<String> _locallyRemovedNames = {};

  String get _header => widget.mode == DayWidgetMode.toTake
      ? pillsToTakeHeader
      : pillsTakenHeader;

  @override
  void initState() {
    super.initState();
    // Seed from the current bloc state so the list is populated on the very
    // first build, before the BlocConsumer listener has a chance to fire.
    final currentState = context.read<PillBloc>().state;
    if (currentState.pillsToTake != null) {
      _localPills = List.from(currentState.pillsToTake!);
    }
  }

  Widget _dismissibleBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade700],
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Delete',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(width: 12),
          Icon(Icons.delete_outline, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  Widget _pillsToTakeList(BuildContext context) {
    final pills = _localPills;
    if (pills == null || pills.isEmpty) {
      return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(_header,
              style:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));
    }

    return ListView.builder(
      itemCount: pills.length,
      itemBuilder: (_, index) {
        final pill = pills[index];
        return Dismissible(
          key: ObjectKey(pill.pillName),
          direction: DismissDirection.endToStart,
          // background is required whenever secondaryBackground is set
          background: const SizedBox.shrink(),
          secondaryBackground: _dismissibleBackground(),
          confirmDismiss: (direction) async {
            final now = widget.dateService.now();
            final todayStr = widget.dateService.formatDateForStorage(now);
            final widgetDateStr =
            widget.dateService.formatDateForStorage(widget.date);

            if (todayStr != widgetDateStr) {
              // Day has rolled over — refresh instead of removing stale data.
              context.read<PillBloc>().add(PillsEvent(
                  eventName: PillEvent.loadPills, date: todayStr));
              return false;
            }
            return true;
          },
          onDismissed: (direction) {
            final widgetDateStr =
            widget.dateService.formatDateForStorage(widget.date);

            // Remove from local list immediately — Flutter requires this.
            setState(() {
              _localPills!.remove(pill);
              _locallyRemovedNames.add(pill.pillName.trim().toLowerCase());
            });

            context.read<PillBloc>().add(PillsEvent(
                eventName: PillEvent.removePill,
                date: widgetDateStr,
                pillToTake: pill));

            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${pill.pillName} removed'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    // Clear tracking synchronously before dispatching so the
                    // listener doesn't block the incoming state update.
                    _locallyRemovedNames
                        .remove(pill.pillName.trim().toLowerCase());
                    context.read<PillBloc>().add(PillsEvent(
                        eventName: PillEvent.addPillToDate,
                        date: widgetDateStr,
                        pillToTake: pill));
                  },
                ),
              ),
            );
          },
          child: PillWidget(
            pillToTake: pill,
            dateService: widget.dateService,
            date: widget.date,
          ),
        );
      },
    );
  }

  Widget _pillsTakenList(BuildContext context, PillState state) {
    List<PillTaken>? pillsTaken = state.pillsTaken;
    if (pillsTaken == null || pillsTaken.isEmpty) {
      return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(_header,
              style:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));
    }

    return ListView.builder(
      itemCount: pillsTaken.length,
      itemBuilder: (_, index) => PillTakenWidget(
          pillTaken: pillsTaken[index], dateService: widget.dateService),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Text(
                    widget.dateService.formatDateForDisplay(widget.date),
                    style: const TextStyle(
                        fontSize: 25.0, fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: BlocConsumer<PillBloc, PillState>(
                // Always listen in toTake mode so that undo — which restores
                // the list to a state equal to a previous one — still triggers
                // the listener despite Equatable seeing no change.
                listenWhen: (previous, current) =>
                widget.mode == DayWidgetMode.toTake,
                listener: (context, state) {
                  final blocPills = state.pillsToTake != null
                      ? List<PillToTake>.from(state.pillsToTake!)
                      : <PillToTake>[];

                  // If the bloc is emitting a state that still contains a pill
                  // we dismissed locally (dismiss animation still in flight),
                  // ignore it — we'll get another emission once removal lands.
                  final hasStillRemovedPill = blocPills.any((p) =>
                      _locallyRemovedNames
                          .contains(p.pillName.trim().toLowerCase()));
                  if (hasStillRemovedPill) return;

                  setState(() {
                    _localPills = blocPills;
                  });
                },
                buildWhen: (previous, current) {
                  if (widget.mode == DayWidgetMode.toTake) {
                    return true;
                  }
                  return !listEquals(previous.pillsTaken, current.pillsTaken);
                },
                builder: (context, state) {
                  return (widget.mode == DayWidgetMode.toTake)
                      ? _pillsToTakeList(context)
                      : _pillsTakenList(context, state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
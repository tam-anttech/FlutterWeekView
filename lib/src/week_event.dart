import 'package:flutter/material.dart';

// /// Builds an event text widget.
// typedef EventTextBuilder = Widget Function(FlutterWeekViewEvent event,
//     BuildContext context, DayView dayView, double height, double width);

/// Represents a flutter week view event.
class WeekEvent extends Comparable<WeekEvent> {
  /// The event start date & time.
  final TimeOfDay start;

  /// The event end date & time.
  final TimeOfDay end;

  /// day of week
  final List<int> day;

  ///
  final Widget child;

  /// Creates a new flutter week view event instance.
  WeekEvent({
    @required this.start,
    @required this.end,
    @required this.day,
    this.child,

    // this.eventTextBuilder,
  })  : assert(start != null),
        assert(end != null),
        assert(day != null);

  /// Builds the event widget.

  double getTopOffset(double height) {
    final minuteHeight = height / 840;
    return minuteHeight * (start.hour * 60 + start.minute);
  }

  @override
  int compareTo(WeekEvent other) {
    return 1;
  }

  @override
  String toString() {
    final timeStart = start.toString();
    final timeEnd = end.toString();
    final listDay = day.toString();
    return 'Start: $timeStart - End: $timeEnd - Day: $listDay';
  }
}

import 'package:flutter/material.dart';

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

  /// exist event
  final bool existed;

  final dynamic existedKey;

  /// Creates a new flutter week view event instance.
  WeekEvent({
    @required this.start,
    @required this.end,
    @required this.day,
    this.child,
    this.existed,
    this.existedKey,
  })  : assert(start != null),
        assert(end != null),
        assert(day != null);

  @override
  int compareTo(WeekEvent other) {
    return 1;
  }

  @override
  String toString() {
    final timeStart = start.toString();
    final timeEnd = end.toString();
    final listDay = day.toString();
    return 'Start: $timeStart\nEnd: $timeEnd\nDay: $listDay\nExisted: $existed\nExistedKey: $existedKey';
  }

  WeekEvent copyWith({
    TimeOfDay start,
    TimeOfDay end,
    List<int> day,
    Widget child,
    bool existed,
    dynamic existedKey,
  }) =>
      WeekEvent(
        start: start ?? this.start,
        end: end ?? this.end,
        day: day ?? this.day,
        child: child ?? this.child,
        existed: existed ?? this.existed,
        existedKey: existedKey ?? this.existedKey,
      );
}

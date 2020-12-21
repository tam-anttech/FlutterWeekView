import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';

/// First plugin test method.
void main() => runApp(
      MaterialApp(
        home: _FlutterWeekViewDemoApp(),
      ),
    );

/// The demo material app.
class _FlutterWeekViewDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo'),
      ),
      body: FullWeekView(
        minimumTime: const TimeOfDay(hour: 6, minute: 0),
        events: [
          WeekEvent(
              start: const TimeOfDay(hour: 8, minute: 25),
              end: const TimeOfDay(hour: 9, minute: 25),
              day: [0, 1]),
          WeekEvent(
              start: const TimeOfDay(hour: 12, minute: 25),
              end: const TimeOfDay(hour: 14, minute: 55),
              day: [2]),
          WeekEvent(
              start: const TimeOfDay(hour: 11, minute: 0),
              end: const TimeOfDay(hour: 16, minute: 15),
              day: [5, 6])
        ],
        onEventSelect: (event) => print(event.toString()),
      ),
    );
  }
}

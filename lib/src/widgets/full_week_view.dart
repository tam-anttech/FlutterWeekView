import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/controller/day_view.dart';
import 'package:flutter_week_view/src/week_event.dart';
import 'package:flutter_week_view/src/styles/day_bar.dart';
import 'package:flutter_week_view/src/styles/day_view.dart';
import 'package:flutter_week_view/src/styles/hours_column.dart';
import 'package:flutter_week_view/src/utils/builders.dart';
import 'package:flutter_week_view/src/utils/event_grid.dart';
import 'package:flutter_week_view/src/utils/hour_minute.dart';
import 'package:flutter_week_view/src/utils/scroll.dart';
import 'package:flutter_week_view/src/widgets/hours_column.dart';
import 'package:flutter_week_view/src/widgets/week_bar.dart';
import 'package:flutter_week_view/src/widgets/zoomable_header_widget.dart';

typedef EvenSelectCallback = Function(WeekEvent event);

/// A (scrollable) day view which is able to display events, zoom and un-zoom and more !
class FullWeekView
    extends ZoomableHeadersWidget<DayViewStyle, DayViewController> {
  /// The events.
  final List<WeekEvent> events;

  /// The day view date.
  final DateTime date;

  /// The day bar style.
  final DayBarStyle dayBarStyle;

  /// EvenSelectCallback
  final EvenSelectCallback onEventSelect;

  /// Creates a new day view instance.
  FullWeekView({
    List<WeekEvent> events,
    DateTime date,
    DayViewStyle style,
    HoursColumnStyle hoursColumnStyle,
    DayBarStyle dayBarStyle,
    DayViewController controller,
    bool inScrollableWidget,
    TimeOfDay minimumTime,
    TimeOfDay maximumTime,
    HourMinute initialTime,
    bool userZoomable,
    EvenSelectCallback onEventSelect,
  })  : date = DateTime.now(),
        events = events ?? [],
        dayBarStyle = dayBarStyle ?? DayBarStyle.fromDate(date: DateTime.now()),
        onEventSelect = onEventSelect,
        super(
          style: style ?? DayViewStyle.fromDate(date: DateTime.now()),
          hoursColumnStyle: hoursColumnStyle ?? const HoursColumnStyle(),
          controller: controller ?? DayViewController(),
          inScrollableWidget: inScrollableWidget ?? true,
          minimumTime: HourMinute.fromTimeOfDay(
                timeOfDay: minimumTime ?? const TimeOfDay(hour: 6, minute: 0),
              ) ??
              HourMinute.MIN,
          maximumTime: HourMinute.fromTimeOfDay(
                timeOfDay: maximumTime ?? const TimeOfDay(hour: 24, minute: 0),
              ) ??
              HourMinute.MAX,
          initialTime: (initialTime ?? HourMinute.MIN).atDate(DateTime.now()),
          userZoomable: userZoomable ?? true,
          hoursColumnTimeBuilder: DefaultBuilders.defaultHoursColumnTimeBuilder,
          currentTimeIndicatorBuilder:
              DefaultBuilders.defaultCurrentTimeIndicatorBuilder,
        );

  @override
  State<StatefulWidget> createState() => _FullWeekViewState();
}

/// The day view state.
class _FullWeekViewState extends ZoomableHeadersWidgetState<FullWeekView> {
  double maxHeight;
  bool isMinHeight;
  Offset selectionStart;
  Offset selectionUpdate;

  @override
  void initState() {
    super.initState();
    scheduleScrollToInitialTime();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(createEventsDrawProperties);
      }
    });
  }

  @override
  void didUpdateWidget(FullWeekView oldWidget) {
    super.didUpdateWidget(oldWidget);
    createEventsDrawProperties();
  }

  void updateMinZoom(double minZoom) {
    widget.controller.minZoom = minZoom;
  }

  @override
  Widget build(BuildContext context) {
    Widget mainWidget = createMainWidget();
    if (widget.style.headerSize > 0 || widget.hoursColumnStyle.width > 0) {
      mainWidget = Stack(
        children: [
          mainWidget,
          Positioned(
            top: 0,
            left: widget.hoursColumnStyle.width,
            right: 0,
            child: WeekBar.fromHeadersWidgetState(
              parent: widget,
              style: widget.dayBarStyle,
              width: double.infinity,
            ),
          ),
          Container(
            height: widget.style.headerSize,
            width: widget.hoursColumnStyle.width,
            color: widget.dayBarStyle.color,
          ),
        ],
      );
    }

    if (!isZoomable) {
      return mainWidget;
    }
    return GestureDetector(
      onScaleStart: (_) => widget.controller.scaleStart(),
      onScaleUpdate: widget.controller.scaleUpdate,
      child: LayoutBuilder(
        builder: (context, constraints) {
          maxHeight ??= constraints.maxHeight - widget.style.headerSize;
          return mainWidget;
        },
      ),
    );
  }

  @override
  void onZoomFactorChanged(
      DayViewController controller, ScaleUpdateDetails details) {
    super.onZoomFactorChanged(controller, details);

    if (mounted) {
      setState(createEventsDrawProperties);
    }
  }

  @override
  DayViewStyle get currentDayViewStyle => widget.style;

  Widget weekBuilder() {
    final dragWidth =
        MediaQuery.of(context).size.width - widget.hoursColumnStyle.width;
    final eventWidth = dragWidth / 7;
    final children = widget.events
        .map((entry) {
          final timeStartObj = HourMinute.fromTimeOfDay(timeOfDay: entry.start);
          final timeEndObj = HourMinute.fromTimeOfDay(timeOfDay: entry.end);
          return entry.day
              .map((e) => Positioned(
                    top: calculateTopOffset(timeStartObj),
                    left: e * eventWidth,
                    child: InkWell(
                      onTap: () =>
                          widget.onEventSelect(entry.copyWith(existed: true)),
                      child: Container(
                        width: eventWidth,
                        height: calculateTopOffset(timeEndObj) -
                            calculateTopOffset(timeStartObj),
                        child: entry.child,
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xffcdebef), Color(0xff40798d)]),
                            border: Border.all(
                                color: const Color(0xffd8eaf3), width: 0.5)),
                      ),
                    ),
                  ))
              .toList();
        })
        .toList()
        .expand((element) => element)
        .toList();

    final curMaxHeight = maxHeight ?? MediaQuery.of(context).size.height;
    final isMinScale = calculateHeight() <= curMaxHeight;
    if (isMinScale &&
        widget.controller.minZoom < widget.controller.zoomFactor) {
      updateMinZoom(widget.controller.zoomFactor);
    }

    return GestureDetector(
      onTapUp: (details) {
        final startTime = calculateTimeOfDay(details.localPosition.dy);
        final endTime = startTime.replacing(hour: startTime.hour + 1);
        final listDay = calculateDay(details.localPosition.dx, eventWidth);
        widget.onEventSelect(
          WeekEvent(start: startTime, end: endTime, day: listDay),
        );
      },
      onVerticalDragStart: isMinScale
          ? (details) => selectionStart = details.localPosition
          : null,
      onVerticalDragUpdate: isMinScale
          ? (details) => selectionUpdate = details.localPosition
          : null,
      onVerticalDragEnd: isMinScale
          ? (details) {
              final startTime = calculateTimeOfDay(selectionStart.dy);
              final endTime = calculateTimeOfDay(selectionUpdate.dy);
              widget.onEventSelect(
                  WeekEvent(start: startTime, end: endTime, day: [0]));
            }
          : null,
      child: Container(
          width: double.infinity,
          color: const Color.fromRGBO(240, 247, 250, 1),
          child: Stack(children: children)),
    );
  }

  /// Creates the main widget, with a hours column and an events column.
  Widget createMainWidget() {
    List<Widget> children = [];

    children.add(Padding(
      padding: EdgeInsets.only(left: widget.hoursColumnStyle.width),
      child: weekBuilder(),
    ));

    if (widget.hoursColumnStyle.width > 0) {
      children.add(Positioned(
        top: 0,
        left: 0,
        child: HoursColumn.fromHeadersWidgetState(parent: this),
      ));
    }

    Widget mainWidget = SizedBox(
      height: calculateHeight(),
      child: Stack(children: children),
    );

    if (verticalScrollController != null) {
      mainWidget = NoGlowBehavior.noGlow(
        child: SingleChildScrollView(
          controller: verticalScrollController,
          child: mainWidget,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: widget.style.headerSize),
      child: mainWidget,
    );
  }

  /// Creates the events draw properties and add them to the current list.
  void createEventsDrawProperties() {
    EventGrid eventsGrid = EventGrid();

    if (eventsGrid.drawPropertiesList.isNotEmpty) {
      double eventsColumnWidth =
          (context.findRenderObject() as RenderBox).size.width -
              widget.hoursColumnStyle.width;
      eventsGrid.processEvents(
          widget.hoursColumnStyle.width, eventsColumnWidth);
    }
  }
}

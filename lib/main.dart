import 'package:flutter/material.dart';

import 'agenda-painter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drag & Drop demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Drag & Drop demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<SchedulePeriod> scheduledPeriods = [
    SchedulePeriod(x: 0, y: 0, width: 500, height: 100),
    SchedulePeriod(
      x: 150,
      y: 220,
      width: 400,
      height: 100,
      children: [
        Event(id: 'Event 3', x: 100, width: 200),
      ],
    ),
    SchedulePeriod(
      x: 525,
      y: 110,
      width: 800,
      height: 100,
      children: [
        Event(id: 'Event 1', x: 100, width: 200),
        Event(id: 'Event 2', x: 320, width: 50),
      ],
    ),
  ];

  void moveChild(int zoneIndex, Event movedEvent, Offset offset) {
    setState(() {
      movedEvent.x = offset.dx;
      this.scheduledPeriods.asMap().forEach((int index, SchedulePeriod scheduledPeriod) {
        scheduledPeriod.children = List.from(scheduledPeriod.children);
        scheduledPeriod.children.remove(movedEvent);
        if (index == zoneIndex) {
          scheduledPeriod.children.add(movedEvent);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SizedBox.fromSize(
          size: Size(1000, 800),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xff7c94b6)),
            ),
            child: CustomPaint(
              painter: AgendaPainter(),
              child: Stack(
                children: scheduledPeriods
                    .asMap()
                    .map(
                      (int index, SchedulePeriod scheduledPeriod) {
                        return MapEntry(
                            index, Zone(scheduledPeriod, droppedCallback: (Event event, Offset offset) => moveChild(index, event, offset)));
                      },
                    )
                    .values
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Zone extends StatelessWidget {
  SchedulePeriod scheduledPeriod;
  DroppedCallback droppedCallback;

  Zone(this.scheduledPeriod, {this.droppedCallback, Key key});

  Widget viewEvent(Event event) {
    return Positioned.fromRect(
      rect: Rect.fromLTWH(event.x, 0, event.width, 50),
      child: Draggable<Event>(
        data: event,
        child: DecoratedBox(
          decoration: BoxDecoration(color: Color(0xdd2c34b6)),
          child: Text(event.id),
        ),
        childWhenDragging: DecoratedBox(
          decoration: BoxDecoration(color: Color(0xffffffb6)),
          child: Text(event.id),
        ),
        feedback: DecoratedBox(
          decoration: BoxDecoration(color: Color(0xdd2c34d6)),
          child: Text(event.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: Offset(scheduledPeriod.x, scheduledPeriod.y) & Size(scheduledPeriod.width, scheduledPeriod.height),
      child: DragTarget<Event>(
        onAcceptWithDetails: (DragTargetDetails<Event> details) {
          final RenderBox renderBox = context.findRenderObject();
          Offset fromZero = renderBox.localToGlobal(Offset.zero);
          if (this.droppedCallback != null) {
            droppedCallback(details.data, details.offset - fromZero);
          }
        },
        builder: (BuildContext context, List<Event> candidateData, List<dynamic> rejectedData) {
          return DecoratedBox(
            decoration: BoxDecoration(color: Color(candidateData.isEmpty ? 0xff7c94b6 : 0xff0000ff)),
            child: Stack(children: scheduledPeriod.children.map(viewEvent).toList()),
          );
        },
      ),
    );
  }
}

typedef DroppedCallback = void Function(Event id, Offset offset);

class SchedulePeriod {
  double x;
  double y;
  double width;
  double height;
  List<Event> children;

  SchedulePeriod({this.x, this.y, this.width, this.height, this.children = const []});
}

class Event {
  double x;
  double width;
  String id;

  Event({this.x, this.width, this.id});
}

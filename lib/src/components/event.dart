import 'package:ical/serializer.dart';
import 'package:ical/src/abstract.dart';
import 'package:ical/src/properties.dart';
import 'package:ical/src/utils.dart' as utils;

class IEvent extends ICalendarElement with EventToDo {
  IEventStatus status = IEventStatus.CONFIRMED;
  DateTime start;
  DateTime end;
  Duration duration;
  ITimeTransparency transparency = ITimeTransparency.OPAQUE;

  String location;
  double lat, lng;
  List<String> resources;
  IAlarm alarm;
  IOrganizer organizer;
  int priority;

  IEvent({
    IOrganizer organizer,
    String uid,
    this.status,
    this.start,
    this.end,
    this.duration,
    String summary,
    String description,
    List<String> categories,
    String url,
    IClass classification,
    String comment,
    IRecurrenceRule rrule,
    this.transparency,
    this.location,
    this.lat,
    this.lng,
    this.resources,
    this.alarm,
    this.priority = 0,
  }) : super(
          organizer: organizer,
          uid: uid,
          summary: summary,
          description: description,
          categories: categories,
          url: url,
          classification: classification,
          comment: comment,
          rrule: rrule,
        );

  @override
  String serialize() {
    super.serialize();
    var out = StringBuffer()
      ..writeln('BEGIN:VEVENT')
      ..writeln('DTSTAMP:${utils.formatDateTime(start ?? DateTime.now())}');

    if ((end == null && duration == null)) {
      out.writeln('DTSTART;VALUE=DATE:${utils.formatDate(start)}');
    } else {
      out.writeln('DTSTART:${utils.formatDateTime(start)}');
    }

    if (end != null) {
      out.writeln('DTEND:${utils.formatDateTime(end)}');
    }
    if (duration != null) {
      out.writeln('DURATION:${utils.formatDuration(duration)}');
    }

    out
      ..writeln('TRANSP:$transparency')
      ..writeln('STATUS:$status')
      ..write(super.serialize())
      ..write(serializeEventToDo())
      ..writeln('END:VEVENT');
    return out.toString();
  }
}

class IEventStatus {
  final String _label;
  @override
  toString() => _label;

  const IEventStatus._(this._label);
  static const TENTATIVE = IEventStatus._('TENTATIVE');
  static const CONFIRMED = IEventStatus._('CONFIRMED');
  static const CANCELLED = IEventStatus._('CANCELLED');
}

class ITimeTransparency {
  final String _label;
  @override
  toString() => _label;
  const ITimeTransparency._(this._label);
  static const OPAQUE = ITimeTransparency._('OPAQUE');
  static const TRANSPARENT = ITimeTransparency._('TRANSPARENT');
}

mixin EventToDo {
  String location;
  double lat;
  double lng;
  int priority;
  List<String> resources;
  IAlarm alarm;

  String serializeEventToDo() {
    var out = StringBuffer();
    if (location != null) out.writeln('LOCATION:$location');
    if (lat != null && lng != null) out.writeln('GEO:$lat;$lng');
    if (resources != null) out.writeln('RESOURCES:${resources.join(',')}');
    if (priority != null) {
      priority = (priority >= 0 && priority <= 9) ? priority : 0;
      out.writeln('PRIORITY:${priority}');
    }
    if (alarm != null) out.write(alarm.serialize());

    return out.toString();
  }
}

import 'package:equatable/equatable.dart';

enum Severity { low, medium, high }

abstract class SiteEvent extends Equatable {
  final String eventId;
  final String siteId;
  final DateTime timestamp;
  const SiteEvent({
    required this.eventId,
    required this.siteId,
    required this.timestamp,
  });
  String get summary; //short summary of the event
  @override
  List<Object?> get props => [eventId, siteId, timestamp];
}

class LaborEvent extends SiteEvent {
  final int workerCount;
  final String description;
  const LaborEvent({
    required String eventId,
    required String siteId,
    required DateTime timestamp,
    required this.workerCount,
    required this.description,
  }) : super(eventId: eventId, siteId: siteId, timestamp: timestamp);
  @override
  String get summary => 'Labor Event: $workerCount workers - $description';
  @override
  List<Object?> get props => super.props + [workerCount, description];
}

class SafetyIncident extends SiteEvent {
  final String description;
  final Severity severity;

  const SafetyIncident({
    required String eventId,
    required String siteId,
    required DateTime timestamp,
    required this.description,
    required this.severity,
  }) : super(eventId: eventId, siteId: siteId, timestamp: timestamp);

  @override
  String get summary => 'Safety Incident: $description (Severity: $severity)';
  @override
  List<Object?> get props => super.props + [description, severity];
}

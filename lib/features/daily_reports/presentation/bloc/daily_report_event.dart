import 'package:equatable/equatable.dart';
import 'package:sitelog/features/daily_reports/domain/entities/site_event.dart';

abstract class DailyReportEvent extends Equatable {
  const DailyReportEvent();
  @override
  List<Object?> get props => [];
}

class LoadEvents extends DailyReportEvent {
  final String siteId;
  const LoadEvents(this.siteId);
  @override
  List<Object?> get props => [siteId];
}

class AddEvent extends DailyReportEvent {
  final SiteEvent event;
  const AddEvent(this.event);
  @override
  List<Object?> get props => [event];
}

class DeleteEvent extends DailyReportEvent {
  final String eventId;
  const DeleteEvent(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

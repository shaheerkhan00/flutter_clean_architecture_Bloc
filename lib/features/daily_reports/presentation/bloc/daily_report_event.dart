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
  final String? uiMessage;
  const AddEvent(this.event, {this.uiMessage});
  @override
  List<Object?> get props => [event, uiMessage];
}

class DeleteEvent extends DailyReportEvent {
  final String eventId;
  final String? uiMessage;
  const DeleteEvent(this.eventId, {this.uiMessage});
  @override
  List<Object?> get props => [eventId, uiMessage];
}

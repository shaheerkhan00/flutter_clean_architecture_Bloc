import 'package:equatable/equatable.dart';
import '../../domain/entities/site_event.dart';

abstract class DailyReportState extends Equatable {
  const DailyReportState();
  @override
  List<Object?> get props => [];
}

class DailyReportInitial extends DailyReportState {}

class DailyReportLoading extends DailyReportState {}

class DailyReportLoaded extends DailyReportState {
  final List<SiteEvent> events;
  const DailyReportLoaded(this.events);
  @override
  List<Object?> get props => [events];
}

class DailyReportError extends DailyReportState {
  final String message;
  const DailyReportError(this.message);
  @override
  List<Object?> get props => [message];
}

import '../entities/site_event.dart';
import '../repositories/report_repository.dart';

class AddSiteEvent {
  final ReportRepository repository;
  AddSiteEvent(this.repository);
  Future<void> call(SiteEvent event) async {
    if (event.timestamp.isAfter(DateTime.now())) {
      throw ArgumentError('Event timestamp cannot be in the future');
    }
    if (event.description.trim().isEmpty) {
      throw ArgumentError('Event description cannot be empty');
    }
    if (event is LaborEvent && event.workerCount <= 0) {
      throw ArgumentError('Worker count cannot be less than 1');
    }
    await repository.addSiteEvent(event);
  }
}

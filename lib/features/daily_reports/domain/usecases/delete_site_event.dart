import '../repositories/report_repository.dart';

class DeleteSiteEvent {
  final ReportRepository repository;

  DeleteSiteEvent(this.repository);

  Future<void> call(String eventId) async {
    // Potential Future Logic: "Are you allowed to delete this?"
    // For now, just pass it through.
    return repository.deleteSiteEvent(eventId);
  }
}

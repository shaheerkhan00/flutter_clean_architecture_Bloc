import '../repositories/report_repository.dart';

class SyncDailyReports {
  final ReportRepository repository;

  SyncDailyReports(this.repository);

  Future<void> call() async {
    // This allows the UI to manually trigger a sync (e.g., Pull-to-Refresh)
    return repository.syncEvents();
  }
}

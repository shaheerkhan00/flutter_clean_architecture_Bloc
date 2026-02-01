import 'package:sitelog/features/daily_reports/domain/repositories/report_repository.dart';
import '../entities/site_event.dart';

class GetSiteEvents {
  final ReportRepository repository;
  GetSiteEvents(this.repository);
  Stream<List<SiteEvent>> call(String siteId) {
    return repository.getEventsForSite(siteId);
  }
}

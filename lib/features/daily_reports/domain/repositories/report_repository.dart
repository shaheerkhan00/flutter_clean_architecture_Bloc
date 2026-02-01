import '../entities/site_event.dart';

abstract class ReportRepository {
  //fetch automatically when data changes, live stream
  Stream<List<SiteEvent>> getEventsForSite(String siteId);
  Future<void> addSiteEvent(SiteEvent event);
  Future<void> deleteSiteEvent(String eventId);
  //syncronise with cloud, pushes data to remote
  Future<void> syncEvents();
}

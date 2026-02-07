import '../../domain/entities/site_event.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/local/local_database.dart';
import 'package:drift/drift.dart';

class ReportRepositoryImpl implements ReportRepository {
  final AppDatabase database;
  ReportRepositoryImpl(this.database);
  @override
  Future<void> addSiteEvent(SiteEvent event) async {
    print("add event called in repository with event: ${event.eventId}");
    final companion = _maptoCompanion(event);
    await database.insertEvent(companion);
  }

  @override
  Future<void> deleteSiteEvent(String eventId) async {
    await database.deleteEvent(eventId);
  }

  @override
  Stream<List<SiteEvent>> getEventsForSite(String siteId) {
    // TODO: implement getEventsForSite
    return database.watchAllEvents(siteId).map((localList) {
      return localList.map(_mapToEntity).toList();
    });
  }

  @override
  Future<void> syncEvents() async {
    // We will implement the Cloud Sync logic here later.
    // For now, it stays empty or just logs a message.
    await Future.delayed(const Duration(seconds: 1)); // Simulate some delay
    print("Sync triggered (Not implemented yet)");
  }

  //helper functionsa

  SiteEvent _mapToEntity(LocalSiteEvent record) {
    if (record.type == 'labor') {
      return LaborEvent(
        eventId: record.eventId,
        siteId: record.siteId,
        timestamp: record.timestamp,
        workerCount: record.workerCount ?? 0,
        description: record.description,
      );
    } else {
      Severity incidentSeverity;

      if (record.severity == 'Severity.low') {
        incidentSeverity = Severity.low;
      } else if (record.severity == 'Severity.medium') {
        incidentSeverity = Severity.medium;
      } else if (record.severity == 'Severity.high') {
        incidentSeverity = Severity.high;
      } else {
        incidentSeverity = Severity.low; // Default fallback
      }
      return SafetyIncident(
        eventId: record.eventId,
        siteId: record.siteId,
        timestamp: record.timestamp,
        description: record.description,
        severity: incidentSeverity,
      );
    }
  }

  LocalSiteEventsCompanion _maptoCompanion(SiteEvent event) {
    final base = LocalSiteEventsCompanion(
      eventId: Value(event.eventId),
      siteId: Value(event.siteId),
      timestamp: Value(event.timestamp),
      description: Value(event.description),
      syncstatus: const Value(0),
    );
    if (event is LaborEvent) {
      return base.copyWith(
        type: const Value('labor'),
        workerCount: Value(event.workerCount),
        severity: const Value.absent(),
      );
    } else if (event is SafetyIncident) {
      return base.copyWith(
        type: const Value('safety'),
        workerCount: const Value.absent(),
        severity: Value(event.severity.toString()),
      );
    }
    throw Exception('Unknown SiteEvent type');
  }
}

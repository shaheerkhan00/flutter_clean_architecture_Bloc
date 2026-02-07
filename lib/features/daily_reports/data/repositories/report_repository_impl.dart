import 'package:sitelog/features/daily_reports/data/datasources/remote/report_remote_data_source.dart';
import 'package:sitelog/features/daily_reports/data/models/site_event_model.dart';

import '../../domain/entities/site_event.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/local/local_database.dart';
import 'package:drift/drift.dart';

class ReportRepositoryImpl implements ReportRepository {
  final AppDatabase database;
  final ReportRemoteDataSource remoteDataSource;
  ReportRepositoryImpl({
    required this.database,
    required this.remoteDataSource,
  });
  @override
  Future<void> addSiteEvent(SiteEvent event) async {
    print("add event called in repository with event: ${event.eventId}");
    final companion = _maptoCompanion(event);
    await database.insertEvent(companion);
    try {
      await _uploadToCloud(event);
      await database.markAsSynced(event.eventId);
    } catch (e) {
      print("Failed to sync event ${event.eventId}: $e");
    }
  }

  @override
  Future<void> deleteSiteEvent(String eventId) async {
    await database.deleteEvent(eventId);
    try {
      await remoteDataSource.deleteEvent(eventId);
    } catch (e) {
      print("Failed to delete event $eventId from cloud: $e");
    }
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
    final pendingEvents = await database.getPendingEvents();
    if (pendingEvents.isEmpty) {
      return;
    }
    for (final localRecord in pendingEvents) {
      try {
        final event = _mapToEntity(localRecord);
        await _uploadToCloud(event);
        await database.markAsSynced(event.eventId);
      } catch (e) {
        print("Failed to sync event ${localRecord.eventId}: $e");
      }
    }
  }

  //helper functionsa
  Future<void> _uploadToCloud(SiteEvent event) async {
    if (event is LaborEvent) {
      final model = LaborEventModel(
        eventId: event.eventId,
        siteId: event.siteId,
        timestamp: event.timestamp,
        workerCount: event.workerCount,
        description: event.description,
      );
      await remoteDataSource.addLaborEvent(model);
    } else if (event is SafetyIncident) {
      final model = SafetyIncidentModel(
        eventId: event.eventId,
        siteId: event.siteId,
        timestamp: event.timestamp,
        description: event.description,
        severity: event.severity,
      );
      await remoteDataSource.addSafetyEvent(model);
    }
  }

  SiteEvent _mapToEntity(LocalSiteEvent record) {
    final bool synced = record.syncstatus == 1;
    if (record.type == 'labor') {
      return LaborEvent(
        eventId: record.eventId,
        siteId: record.siteId,
        timestamp: record.timestamp,
        workerCount: record.workerCount ?? 0,
        description: record.description,
        isSynced: synced,
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
        isSynced: synced,
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

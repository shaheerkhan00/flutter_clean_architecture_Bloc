import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'local_database.g.dart';

//table definition, sql schema written in dart
class LocalSiteEvents extends Table {
  TextColumn get eventId => text()();
  TextColumn get siteId => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get description => text()();

  //discriminator for event type
  TextColumn get type => text()();
  //fields specific to LaborEvent
  IntColumn get workerCount => integer().nullable()();
  //fields specific to SafetyIncident
  TextColumn get severity => text().nullable()();
  //syncing
  IntColumn get syncstatus => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {eventId};
}

@DriftDatabase(tables: [LocalSiteEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  //get all events query
  Stream<List<LocalSiteEvent>> watchAllEvents(String siteId) {
    return (select(
      localSiteEvents,
    )..where((tbl) => tbl.siteId.equals(siteId))).watch();
  }

  //insert event
  Future<int> insertEvent(LocalSiteEventsCompanion event) {
    return into(localSiteEvents).insert(event);
  }

  //delete event
  Future<int> deleteEvent(String Id) {
    return (delete(
      localSiteEvents,
    )..where((tbl) => tbl.eventId.equals(Id))).go();
  }

  //get all unsynced events
  Future<List<LocalSiteEvent>> getPendingEvents() {
    return (select(
      localSiteEvents,
    )..where((tbl) => tbl.syncstatus.equals(0))).get();
  }

  //mark event as synced
  Future<void> markAsSynced(String id) {
    return (update(localSiteEvents)..where((tbl) => tbl.eventId.equals(id)))
        .write(const LocalSiteEventsCompanion(syncstatus: Value(1)));
  }

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sitelog_db.sqlite'));
    return NativeDatabase(file);
  });
}

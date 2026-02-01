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

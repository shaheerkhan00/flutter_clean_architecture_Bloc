import 'package:get_it/get_it.dart';
import 'package:sitelog/features/daily_reports/domain/usecases/get_site_events.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/daily_reports/data/datasources/local/local_database.dart';
import 'features/daily_reports/data/repositories/report_repository_impl.dart';
import 'features/daily_reports/domain/repositories/report_repository.dart';
import 'features/daily_reports/domain/usecases/add_site_event.dart';
import 'features/daily_reports/domain/usecases/delete_site_event.dart';
import 'features/daily_reports/domain/usecases/sync_daily_reports.dart';
import 'features/daily_reports/presentation/bloc/daily_report_bloc.dart';
import 'features/daily_reports/data/datasources/remote/report_remote_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //external
  sl.registerLazySingleton(() => Supabase.instance.client);
  //db
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  //remote
  sl.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSourceImpl(sl()),
  );
  //repositories
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(database: sl(), remoteDataSource: sl()),
  );
  //use cases
  sl.registerLazySingleton<AddSiteEvent>(() => AddSiteEvent(sl()));
  sl.registerLazySingleton<GetSiteEvents>(() => GetSiteEvents(sl()));
  sl.registerLazySingleton<DeleteSiteEvent>(() => DeleteSiteEvent(sl()));
  sl.registerLazySingleton<SyncDailyReports>(() => SyncDailyReports(sl()));

  //bloc
  sl.registerFactory(
    () => DailyReportBloc(
      getSiteEvents: sl(), // Inject Use Case 1
      addSiteEvent: sl(), // Inject Use Case 2
      deleteSiteEvent: sl(),
      syncDailyReports: sl(), // Inject Use Case 3
    ),
  );
}

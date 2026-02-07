import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sitelog/features/daily_reports/domain/usecases/sync_daily_reports.dart';
import '../../domain/entities/site_event.dart';
import '../../domain/usecases/add_site_event.dart';
import '../../domain/usecases/delete_site_event.dart';
import '../../domain/usecases/get_site_events.dart';
import 'daily_report_event.dart';
import 'daily_report_state.dart';

class DailyReportBloc extends Bloc<DailyReportEvent, DailyReportState> {
  final GetSiteEvents getSiteEvents;
  final AddSiteEvent addSiteEvent;
  final DeleteSiteEvent deleteSiteEvent;
  final SyncDailyReports syncDailyReports;
  DailyReportBloc({
    required this.getSiteEvents,
    required this.addSiteEvent,
    required this.deleteSiteEvent,
    required this.syncDailyReports,
  }) : super(DailyReportInitial()) {
    on<LoadEvents>((event, emit) async {
      emit(DailyReportLoading());

      await emit.forEach<List<SiteEvent>>(
        getSiteEvents(event.siteId),
        onData: (list) => DailyReportLoaded(list),
        onError: (error, stackTrace) => DailyReportError(error.toString()),
      );
    });
    on<AddEvent>((event, emit) async {
      try {
        await addSiteEvent(event.event);
      } catch (e) {
        if (state is DailyReportLoaded) {
          final currentList = (state as DailyReportLoaded).events;
          emit(DailyReportLoaded(currentList, uiMessage: e.toString()));
          emit(DailyReportLoaded(currentList, uiMessage: null));
        } else {
          emit(const DailyReportError("Failed to add event"));
        }
      }
    });
    on<DeleteEvent>((event, emit) async {
      try {
        await deleteSiteEvent(event.eventId);
      } catch (e) {
        if (state is DailyReportLoaded) {
          final currentList = (state as DailyReportLoaded).events;
          emit(DailyReportLoaded(currentList, uiMessage: e.toString()));
          emit(DailyReportLoaded(currentList, uiMessage: null));
        } else {
          emit(const DailyReportError("Failed to delete event"));
        }
      }
    });
    on<SyncReportsEvent>(_onSyncReports);
  }
  Future<void> _onSyncReports(
    SyncReportsEvent event,
    Emitter<DailyReportState> emit,
  ) async {
    if (state is DailyReportLoaded) {
      final currentEvents = (state as DailyReportLoaded).events;
      emit(DailyReportLoaded(currentEvents, uiMessage: "Syncing..."));
      emit(DailyReportLoaded(currentEvents, uiMessage: null));
      try {
        await syncDailyReports();
        emit(DailyReportLoaded(currentEvents, uiMessage: "Sync completed"));
        emit(DailyReportLoaded(currentEvents, uiMessage: null));
      } catch (e) {
        emit(DailyReportLoaded(currentEvents, uiMessage: "Sync failed: $e"));
        emit(DailyReportLoaded(currentEvents, uiMessage: null));
      }
    }
  }
}

import 'package:supabase/supabase.dart';
import '../../models/site_event_model.dart';

abstract class ReportRemoteDataSource {
  Future<void> addLaborEvent(LaborEventModel event);
  Future<void> addSafetyEvent(SafetyIncidentModel event);
  Future<void> deleteEvent(String eventId);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final SupabaseClient supabaseClient;
  ReportRemoteDataSourceImpl(this.supabaseClient);
  @override
  Future<void> addLaborEvent(LaborEventModel event) async {
    await supabaseClient.from('site_events').insert(event.toJson());
  }

  @override
  Future<void> addSafetyEvent(SafetyIncidentModel event) async {
    await supabaseClient.from('site_events').insert(event.toJson());
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await supabaseClient.from('site_events').delete().eq('event_id', eventId);
  }
}

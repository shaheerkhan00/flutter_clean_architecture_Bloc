import 'package:json_annotation/json_annotation.dart';
import 'package:sitelog/features/daily_reports/domain/entities/site_event.dart';

part 'site_event_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LaborEventModel extends LaborEvent {
  const LaborEventModel({
    required String eventId,
    required String siteId,
    required DateTime timestamp,
    required int workerCount,
    required String description,
  }) : super(
         eventId: eventId,
         siteId: siteId,
         timestamp: timestamp,
         workerCount: workerCount,
         description: description,
       );

  factory LaborEventModel.fromJson(Map<String, dynamic> json) =>
      _$LaborEventModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$LaborEventModelToJson(this)..['type'] = 'labor';
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SafetyIncidentModel extends SafetyIncident {
  const SafetyIncidentModel({
    required String eventId,
    required String siteId,
    required DateTime timestamp,
    required String description,
    required Severity severity,
  }) : super(
         eventId: eventId,
         siteId: siteId,
         timestamp: timestamp,
         description: description,
         severity: severity,
       );

  factory SafetyIncidentModel.fromJson(Map<String, dynamic> json) =>
      _$SafetyIncidentModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SafetyIncidentModelToJson(this)..['type'] = 'safety';
}

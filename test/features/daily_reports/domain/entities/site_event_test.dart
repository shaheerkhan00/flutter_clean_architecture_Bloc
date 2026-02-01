import 'package:flutter_test/flutter_test.dart';
import 'package:sitelog/features/daily_reports/domain/entities/site_event.dart';

void main() {
  group('SiteEvent Entities', () {
    const tEventId = 'event123';
    const tSiteId = 'site456';
    final tTimestamp = DateTime(2026, 1, 31);
    test('LaborEvent should support equality', () {
      final event1 = LaborEvent(
        eventId: tEventId,
        siteId: tSiteId,
        timestamp: tTimestamp,
        workerCount: 10,
        description: 'framing',
      );
      final event2 = LaborEvent(
        eventId: tEventId,
        siteId: tSiteId,
        timestamp: tTimestamp,
        workerCount: 10,
        description: 'framing',
      );
      //assert
      expect(event1, equals(event2));
    });
    test('Safety incident summary should include severity', () {
      final incident = SafetyIncident(
        eventId: 'safety1',
        siteId: tSiteId,
        timestamp: tTimestamp,
        description: 'slipped',
        severity: Severity.high,
      );
      final result = incident.summary;
      expect(result, contains('Severity: Severity.high'));
    });
    test('LaborEvent summary should include worker count and description', () {
      final laborEvent = LaborEvent(
        eventId: 'labor1',
        siteId: tSiteId,
        timestamp: tTimestamp,
        workerCount: 15,
        description: 'concrete pouring',
      );
      final result = laborEvent.summary;
      expect(result, contains('15 workers'));
      expect(result, contains('concrete pouring'));
    });
  });
}

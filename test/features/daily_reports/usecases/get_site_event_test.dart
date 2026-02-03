import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sitelog/features/daily_reports/domain/entities/site_event.dart';
import 'package:sitelog/features/daily_reports/domain/repositories/report_repository.dart';
import 'package:sitelog/features/daily_reports/domain/usecases/get_site_events.dart';

class MockRepository extends Mock implements ReportRepository {}

void main() {
  late GetSiteEvents useCase;
  late MockRepository mockRepository;
  setUp(() {
    mockRepository = MockRepository();
    useCase = GetSiteEvents(mockRepository);
  });
  const String tSiteId = 'site123';
  var tEvents = <SiteEvent>[
    LaborEvent(
      eventId: 'event1',
      siteId: tSiteId,
      timestamp: DateTime(2026, 1, 30),
      workerCount: 10,
      description: 'Excavation work',
    ),
  ];
  test('Should Return a stream events from repo', () {
    //arrange
    when(
      () => mockRepository.getEventsForSite(tSiteId),
    ).thenAnswer((_) => Stream.value(tEvents));

    //action
    final result = useCase(tSiteId);
    //assert
    expect(result, emits(tEvents));
    verify(() => mockRepository.getEventsForSite(tSiteId)).called(1);
  });
}

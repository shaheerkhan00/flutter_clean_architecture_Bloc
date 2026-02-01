import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sitelog/features/daily_reports/domain/entities/site_event.dart';
import 'package:sitelog/features/daily_reports/domain/repositories/report_repository.dart';
import 'package:sitelog/features/daily_reports/domain/usecases/add_site_event.dart';

class MockRepository extends Mock implements ReportRepository {}

class FakeSiteEvent extends Fake implements SiteEvent {}

void main() {
  late AddSiteEvent useCase;
  late MockRepository mockRepository;
  setUpAll(() {
    registerFallbackValue(FakeSiteEvent());
  });
  setUp(() {
    mockRepository = MockRepository();
    useCase = AddSiteEvent(mockRepository);
  });
  test('should throw argumenterror when timestamp is in the future', () async {
    final futureEvent = LaborEvent(
      eventId: 'event1',
      siteId: 'site1',
      timestamp: DateTime.now().add(Duration(days: 1)),
      workerCount: 5,
      description: 'FutureWork',
    );
    expect(() => useCase(futureEvent), throwsA(isA<ArgumentError>()));
    verifyNever(() => mockRepository.addSiteEvent(any()));
  });
  test('Should call repository when data is valid', () async {
    final validEvent = SafetyIncident(
      eventId: 'safetytest',
      siteId: 'site2',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      description: 'Valid incident',
      severity: Severity.medium,
    );
    when(() => mockRepository.addSiteEvent(any())).thenAnswer((_) async {});
    await useCase(validEvent);
    verify(() => mockRepository.addSiteEvent(validEvent)).called(1);
  });
  test(
    'should throw argument error when labor event has zero worker',
    () async {
      final invalidLaborEvent = LaborEvent(
        eventId: 'laborInvalid',
        siteId: 'site3',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
        workerCount: 0,
        description: 'No workers',
      );
      expect(() => useCase(invalidLaborEvent), throwsA(isA<ArgumentError>()));
      verifyNever(() => mockRepository.addSiteEvent(any()));
    },
  );
}

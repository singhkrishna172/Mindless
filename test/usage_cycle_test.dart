import 'package:flutter_test/flutter_test.dart';
import 'package:mindless/providers/usage_limit_provider.dart';

void main() {
  group('UsageLimitProvider.cycleDayFor', () {
    final start = DateTime(2026, 11, 1);

    test('limits apply for the first six days', () {
      expect(
        UsageLimitProvider.cycleDayFor(start, DateTime(2026, 11, 1)),
        1,
      );
      expect(
        UsageLimitProvider.cycleDayFor(start, DateTime(2026, 11, 6)),
        6,
      );
    });

    test('day seven is unrestricted and day eight starts a new cycle', () {
      expect(
        UsageLimitProvider.cycleDayFor(start, DateTime(2026, 11, 7)),
        7,
      );
      expect(
        UsageLimitProvider.cycleDayFor(start, DateTime(2026, 11, 8)),
        1,
      );
    });

    test('dates before the cycle start remain on day one', () {
      expect(
        UsageLimitProvider.cycleDayFor(start, DateTime(2026, 10, 31)),
        1,
      );
    });
  });
}

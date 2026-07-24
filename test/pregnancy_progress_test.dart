import 'package:flutter_test/flutter_test.dart';
import 'package:mamabloom/models/pregnancy_progress.dart';

void main() {
  group('PregnancyProgress from LMP', () {
    test('LMP day is 0 days elapsed', () {
      final p =
          PregnancyProgress.fromLmp('01/01/2026', now: DateTime(2026, 1, 1))!;
      expect(p.daysElapsed, 0);
      expect(p.weeks, 0);
      expect(p.dayOfWeek, 0);
      expect(p.contentWeek, 1);
      expect(p.weekDayLabel, '0 weeks + 0 days');
    });

    test('days 0–6 stay in week 1', () {
      final p =
          PregnancyProgress.fromLmp('01/01/2026', now: DateTime(2026, 1, 7))!;
      expect(p.daysElapsed, 6);
      expect(p.contentWeek, 1);
      expect(p.weeks, 0);
      expect(p.dayOfWeek, 6);
    });

    test('7 days = week 2, age 1 week + 0 days', () {
      final p =
          PregnancyProgress.fromLmp('01/01/2026', now: DateTime(2026, 1, 8))!;
      expect(p.daysElapsed, 7);
      expect(p.weeks, 1);
      expect(p.dayOfWeek, 0);
      expect(p.contentWeek, 2);
      expect(p.weekDayLabel, '1 week + 0 days');
    });

    test('171 days = 24 weeks + 3 days, in week 25', () {
      final p =
          PregnancyProgress.fromLmp('01/01/2026', now: DateTime(2026, 6, 21))!;
      expect(p.daysElapsed, 171);
      expect(p.weeks, 24);
      expect(p.dayOfWeek, 3);
      expect(p.contentWeek, 25);
      expect(p.weekDayLabel, '24 weeks + 3 days');
    });

    test('280 days = due date', () {
      final p =
          PregnancyProgress.fromLmp('01/01/2026', now: DateTime(2026, 10, 8))!;
      expect(p.daysElapsed, 280);
      expect(p.daysLeft, 0);
      expect(p.edd, DateTime(2026, 10, 8));
      expect(p.contentWeek, 40);
    });

    test('trimester boundaries by completed weeks', () {
      final t1 =
          PregnancyProgress.fromLmp('01/01/2026', now: DateTime(2026, 4, 1))!;
      expect(t1.daysElapsed, 90);
      expect(t1.weeks, 12);
      expect(t1.trimester, 1);

      final t2 =
          PregnancyProgress.fromLmp('01/01/2026', now: DateTime(2026, 4, 2))!;
      expect(t2.daysElapsed, 91);
      expect(t2.weeks, 13);
      expect(t2.trimester, 2);

      final t2b =
          PregnancyProgress.fromLmp('01/01/2026', now: DateTime(2026, 7, 8))!;
      expect(t2b.daysElapsed, 188);
      expect(t2b.weeks, 26);
      expect(t2b.trimester, 2);

      final t3 =
          PregnancyProgress.fromLmp('01/01/2026', now: DateTime(2026, 7, 9))!;
      expect(t3.daysElapsed, 189);
      expect(t3.weeks, 27);
      expect(t3.trimester, 3);
    });

    test('advances each calendar day', () {
      final a =
          PregnancyProgress.fromLmp('15/03/2026', now: DateTime(2026, 3, 20))!;
      final b =
          PregnancyProgress.fromLmp('15/03/2026', now: DateTime(2026, 3, 21))!;
      expect(b.daysElapsed, a.daysElapsed + 1);
      expect(b.dayOfWeek, (a.dayOfWeek + 1) % 7);
    });
  });
}

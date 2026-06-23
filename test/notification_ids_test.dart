import 'package:flutter_test/flutter_test.dart';
import 'package:nmaz_reminder/core/notification_ids.dart';

void main() {
  test('makeNotificationId deterministic', () {
    final id1 = makeNotificationId('uid123', 'fajr', followup: true);
    final id2 = makeNotificationId('uid123', 'fajr', followup: true);
    final id3 = makeNotificationId('uid123', 'dhuhr', followup: true);
    expect(id1, equals(id2));
    expect(id1, isNot(equals(id3)));
  });
}

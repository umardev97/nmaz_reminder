// Date is intentionally excluded so the same ID is used every day.
// Re-scheduling with the same ID replaces the existing scheduled notification,
// preventing duplicate alerts from stacking across logins.
int makeNotificationId(
  String uid,
  String prayer, {
  bool followup = false,
}) {
  final s = '$uid|$prayer|${followup ? 'follow' : 'main'}';
  int h = 0;
  for (var i = 0; i < s.length; i++) {
    h = (h * 31 + s.codeUnitAt(i)) & 0x7fffffff;
  }
  return h % 1000000;
}

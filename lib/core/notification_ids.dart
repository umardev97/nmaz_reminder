int makeNotificationId(
  String uid,
  String date,
  String prayer, {
  bool followup = false,
}) {
  final s = '$uid|$date|$prayer|${followup ? 'follow' : 'main'}';
  int h = 0;
  for (var i = 0; i < s.length; i++) {
    h = (h * 31 + s.codeUnitAt(i)) & 0x7fffffff;
  }
  return h % 1000000; // keep ids within reasonable range
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerTimeService {
  /// Fetch today's prayer times from Aladhan API by latitude & longitude.
  Future<Map<String, String>> fetchTodayTimes(double lat, double lon) async {
    final now = DateTime.now();
    final url = Uri.parse(
      'https://api.aladhan.com/v1/timings/${now.toUtc().millisecondsSinceEpoch ~/ 1000}?latitude=$lat&longitude=$lon&method=2',
    );
    final res = await http.get(url).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Prayer API error: ${res.statusCode}');
    }
    final body = json.decode(res.body) as Map<String, dynamic>;
    final timings = (body['data']?['timings'] ?? {}) as Map<String, dynamic>;
    return timings.map((k, v) => MapEntry(k.toLowerCase(), v.toString()));
  }
}

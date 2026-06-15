import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report_model.dart';
import '../report_repository.dart';

final reportRepositoryProvider = Provider((ref) => ReportRepository());

final todayReportProvider = FutureProvider.family<DailyReport?, String>((
  ref,
  uid,
) async {
  final repo = ref.watch(reportRepositoryProvider);
  final today = DateTime.now();
  final date =
      '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  return repo.fetchReport(uid, date);
});

final saveReportProvider = Provider((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  return (String uid, DailyReport r) async {
    await repo.saveReport(uid, r);
  };
});

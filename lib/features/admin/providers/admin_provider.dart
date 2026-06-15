import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../admin_repository.dart';

final adminRepositoryProvider = Provider((ref) => AdminRepository());

final allUsersStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.streamAllUsers();
});

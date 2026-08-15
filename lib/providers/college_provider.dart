import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/college_model.dart';
import '../repositories/college_repository.dart';
import 'auth_provider.dart';

final collegeRepositoryProvider = Provider<CollegeRepository>((ref) {
  return CollegeRepository();
});

final liveCollegesProvider = FutureProvider<List<CollegeModel>>((ref) async {
  final repo = ref.watch(collegeRepositoryProvider);
  return await repo.fetchLiveColleges();
});

final selectedCollegeProvider = StateProvider<CollegeModel>((ref) {
  final repo = ref.watch(collegeRepositoryProvider);
  final liveCollegesAsync = ref.watch(liveCollegesProvider);
  final authState = ref.watch(authProvider);

  final liveList = liveCollegesAsync.value ?? repo.getAllColleges();

  // If student or parent is logged in and has an institution_id / collegeId
  final instId = authState.student?.collegeId;
  if (instId != null && instId.isNotEmpty && liveList.isNotEmpty) {
    final cleanId = instId.trim().toLowerCase();
    final match = liveList.firstWhere(
      (c) => c.id.toLowerCase() == cleanId || c.code.toLowerCase() == cleanId || c.name.toLowerCase().contains(cleanId),
      orElse: () => liveList.first,
    );
    return match;
  }

  return liveList.isNotEmpty ? liveList.first : repo.getAllColleges().first;
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final recentCollegesProvider = StateProvider<List<CollegeModel>>((ref) {
  final repo = ref.watch(collegeRepositoryProvider);
  final all = repo.getAllColleges();
  return all.take(3).toList();
});

final collegeSearchResultsProvider = Provider<List<CollegeModel>>((ref) {
  final repo = ref.watch(collegeRepositoryProvider);
  final query = ref.watch(searchQueryProvider);
  // Trigger live fetch if future resolved
  ref.watch(liveCollegesProvider);
  return repo.searchColleges(query);
});

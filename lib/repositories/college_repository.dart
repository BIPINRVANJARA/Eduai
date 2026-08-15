import '../core/services/supabase_service.dart';
import '../models/college_model.dart';

class CollegeRepository {
  List<CollegeModel> _cache = [];

  CollegeRepository() {
    fetchLiveColleges();
  }

  Future<List<CollegeModel>> fetchLiveColleges() async {
    final remote = await SupabaseService.fetchInstitutions();
    if (remote != null && remote.isNotEmpty) {
      _cache = remote;
      return remote;
    }
    return _cache;
  }

  List<CollegeModel> getAllColleges() {
    if (_cache.isNotEmpty) return _cache;
    // Default fallback placeholder if Supabase connection is pending
    return const [
      CollegeModel(
        id: 'gph_624',
        name: 'Government Polytechnic Himmatnagar',
        shortName: 'GPH Himmatnagar',
        code: '624',
        city: 'Himmatnagar',
        state: 'Gujarat',
        address: 'Near Motipura Circle, Himmatnagar, Gujarat 383001',
        rating: 4.7,
        studentCount: 5000,
        admissionsOpen: true,
        tags: ['Polytechnic', 'Diploma', 'Government'],
        faqs: {},
        contactPhone: '+91 2772 229100',
        contactEmail: 'gphimmatnagar@gmail.com',
        website: 'https://gph.cteguj.in',
      ),
    ];
  }

  List<CollegeModel> searchColleges(String query) {
    final source = getAllColleges();
    if (query.trim().isEmpty) return source;
    final q = query.toLowerCase();
    return source.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.shortName.toLowerCase().contains(q) ||
          c.city.toLowerCase().contains(q) ||
          c.code.toLowerCase().contains(q) ||
          c.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  CollegeModel getById(String id) {
    final source = getAllColleges();
    final cleanId = id.trim().toLowerCase();
    return source.firstWhere(
      (c) => c.id.toLowerCase() == cleanId || c.code.toLowerCase() == cleanId || c.shortName.toLowerCase().contains(cleanId) || c.name.toLowerCase().contains(cleanId),
      orElse: () => source.first,
    );
  }
}

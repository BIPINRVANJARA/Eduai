import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;
  
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  static User? get currentUser => _client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  /// RFC4122 compliant UUID v4 generator
  static String generateUuidV4() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40; // Version 4
    values[8] = (values[8] & 0x3f) | 0x80; // Variant RFC4122
    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  /// Sign in for Student with approval status verification & auto-provisioning
  static Future<AuthResponse> signInStudent(String email, String password) async {
    final cleanEmail = email.trim();

    try {
      final res = await _client.auth.signInWithPassword(email: cleanEmail, password: password);
      final user = res.user;

      if (user != null) {
        final studentRes = await _client
            .from('students')
            .select('id, status, institution_id')
            .or('profile_id.eq.${user.id},email.eq.$cleanEmail')
            .maybeSingle();

        if (studentRes != null) {
          final status = studentRes['status']?.toString() ?? 'approved';
          if (status == 'pending_approval') {
            await _client.auth.signOut();
            throw Exception('APPROVAL_PENDING: Your account is pending verification by college administration. You will be able to log in once approved.');
          } else if (status == 'rejected') {
            await _client.auth.signOut();
            throw Exception('APPROVAL_REJECTED: Your registration request was declined by the institution administration.');
          }

          // Link profile_id if not yet linked
          if (studentRes['profile_id'] == null) {
            await _client.from('students').update({'profile_id': user.id}).eq('id', studentRes['id']);
          }
        }
      }
      return res;
    } on AuthException catch (e) {
      // If auth fails (e.g. user was approved in admin panel but auth signup was rate-limited earlier)
      final studentRes = await _client
          .from('students')
          .select('*')
          .eq('email', cleanEmail)
          .maybeSingle();

      if (studentRes != null) {
        final status = studentRes['status']?.toString() ?? 'pending_approval';
        if (status == 'pending_approval') {
          throw Exception('APPROVAL_PENDING: Your registration request is awaiting verification by your college administration. Once approved, you will be able to log in immediately.');
        } else if (status == 'rejected') {
          throw Exception('APPROVAL_REJECTED: Your registration request was declined by the institution administration.');
        } else if (status == 'approved') {
          // Student is approved! Auto-provision the Supabase Auth user now
          try {
            final signUpRes = await _client.auth.signUp(
              email: cleanEmail,
              password: password,
              data: {
                'role': 'student',
                'full_name': studentRes['full_name'] ?? '',
                'mobile': studentRes['mobile'] ?? '',
                'institution_id': studentRes['institution_id'] ?? '',
                'enrollment_no': studentRes['enrollment_no'] ?? '',
                'department': studentRes['department'] ?? '',
                'semester': studentRes['semester'] ?? 1,
                'division': studentRes['division'] ?? 'A',
              },
            );

            if (signUpRes.user != null) {
              final newUserId = signUpRes.user!.id;
              await _client.from('students').update({'profile_id': newUserId}).eq('id', studentRes['id']);
              await _client.from('profiles').upsert({
                'id': newUserId,
                'role': 'student',
                'full_name': studentRes['full_name'] ?? '',
                'email': cleanEmail,
                'mobile': studentRes['mobile'] ?? '',
                'institution_id': studentRes['institution_id'] ?? '',
              }, onConflict: 'id');

              return await _client.auth.signInWithPassword(email: cleanEmail, password: password);
            }
          } catch (signUpErr) {
            final msg = signUpErr.toString().toLowerCase();
            if (msg.contains('already registered') || msg.contains('user already exists')) {
              throw Exception('Invalid password for this account. If you forgot your password, tap "Forgot Password?" below.');
            }
          }
        }
      }
      rethrow;
    }
  }

  /// Sign in for Parent using either 10-digit Mobile Number OR Parent Email
  static Future<AuthResponse> signInParent(String identifier, String password) async {
    String loginEmail = identifier.trim();

    // Check if input is a 10-digit mobile number or parent email
    final isMobile = RegExp(r'^[0-9]{10}$').hasMatch(loginEmail);
    
    // Lookup student account email associated with this parent
    if (isMobile) {
      final studentRes = await _client
          .from('students')
          .select('email, parent_email, status')
          .eq('parent_mobile', loginEmail)
          .maybeSingle();

      if (studentRes != null) {
        final status = studentRes['status']?.toString();
        if (status == 'pending_approval') {
          throw Exception('APPROVAL_PENDING: Your student registration is pending approval by the college. Once approved, you can log in.');
        } else if (status == 'rejected') {
          throw Exception('APPROVAL_REJECTED: Your student registration was declined by the college administration.');
        }
        loginEmail = (studentRes['email'] ?? studentRes['parent_email']).toString();
      } else {
        // Fallback check parents table
        final parentRes = await _client
            .from('parents')
            .select('email')
            .eq('mobile', loginEmail)
            .maybeSingle();

        if (parentRes != null && parentRes['email'] != null) {
          loginEmail = parentRes['email'].toString();
        } else {
          throw Exception('No parent account found with mobile number $loginEmail. Please register your student first.');
        }
      }
    } else {
      // Identifier is an email: check if student has this parent email
      final studentRes = await _client
          .from('students')
          .select('email, status')
          .eq('parent_email', loginEmail)
          .maybeSingle();

      if (studentRes != null) {
        final status = studentRes['status']?.toString();
        if (status == 'pending_approval') {
          throw Exception('APPROVAL_PENDING: Your student registration is pending approval by the college. Once approved, you can log in.');
        } else if (status == 'rejected') {
          throw Exception('APPROVAL_REJECTED: Your student registration was declined by the college administration.');
        }
        loginEmail = studentRes['email'].toString();
      }
    }

    // Attempt Supabase Auth login with resolved email & shared student password
    return await signInStudent(loginEmail, password);
  }

  /// Generic fallback signIn
  static Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Future<String?> getUserRole() async {
    if (currentUser == null) return null;
    try {
      final response = await _client
          .from('profiles')
          .select('role')
          .eq('id', currentUser!.id)
          .maybeSingle();
      if (response != null && response['role'] != null) {
        return response['role'] as String?;
      }

      // Fallback check students table
      final studentCheck = await _client
          .from('students')
          .select('id')
          .or('profile_id.eq.${currentUser!.id},email.eq.${currentUser!.email}')
          .maybeSingle();
      if (studentCheck != null) return 'student';

      // Fallback check parents table
      final parentCheck = await _client
          .from('parents')
          .select('id')
          .or('profile_id.eq.${currentUser!.id},email.eq.${currentUser!.email}')
          .maybeSingle();
      if (parentCheck != null) return 'parent';
    } catch (e) {
      // Fallback
    }
    return currentUser?.userMetadata?['role'] as String? ?? 'student';
  }

  static Future<String> registerStudentAccount({
    required String email,
    required String password,
    required String fullName,
    required String mobile,
    String? enrollmentNo,
    String? department,
    String? semester,
    String? division,
    String? parentEmail,
    String? parentMobile,
    String? institutionId,
  }) async {
    String profileId = '';

    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': 'student',
          'full_name': fullName,
          'mobile': mobile,
          if (enrollmentNo != null) 'enrollment_no': enrollmentNo,
          if (department != null) 'department': department,
          if (semester != null) 'semester': semester,
          if (division != null) 'division': division,
          if (parentEmail != null) 'parent_email': parentEmail,
          if (parentMobile != null) 'parent_mobile': parentMobile,
          if (institutionId != null) 'institution_id': institutionId,
        },
      );
      if (res.user != null) {
        profileId = res.user!.id;
      }
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (err.contains('already registered') ||
          err.contains('over_email_send_rate_limit') ||
          err.contains('rate limit') ||
          err.contains('429')) {
        try {
          final loginRes = await _client.auth.signInWithPassword(email: email, password: password);
          if (loginRes.user != null) {
            profileId = loginRes.user!.id;
          }
        } catch (_) {
          try {
            final existing = await _client
                .from('students')
                .select('profile_id')
                .or('email.eq.$email,enrollment_no.eq.${enrollmentNo ?? ""}')
                .maybeSingle();
            if (existing != null && existing['profile_id'] != null) {
              profileId = existing['profile_id'].toString();
            }
          } catch (_) {}
        }
      } else {
        rethrow;
      }
    }

    if (profileId.isEmpty || !RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(profileId)) {
      profileId = generateUuidV4();
    }

    return profileId;
  }

  static Future<AuthResponse> signUpStudent({
    required String email,
    required String password,
    required String fullName,
    required String mobile,
    String? enrollmentNo,
    String? department,
    String? semester,
    String? division,
    String? parentEmail,
    String? parentMobile,
    String? institutionId,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'role': 'student',
        'full_name': fullName,
        'mobile': mobile,
        if (enrollmentNo != null) 'enrollment_no': enrollmentNo,
        if (department != null) 'department': department,
        if (semester != null) 'semester': semester,
        if (division != null) 'division': division,
        if (parentEmail != null) 'parent_email': parentEmail,
        if (parentMobile != null) 'parent_mobile': parentMobile,
        if (institutionId != null) 'institution_id': institutionId,
      },
    );
  }

  static Future<AuthResponse> signUpParent({
    required String email,
    required String password,
    required String fullName,
    required String mobile,
    String? institutionId,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'role': 'parent',
        'full_name': fullName,
        'mobile': mobile,
        if (institutionId != null) 'institution_id': institutionId,
      },
    );
  }

  static Future<void> createStudentRecord({
    String? profileId,
    required String enrollmentNo,
    required String fullName,
    required String email,
    required String mobile,
    required String parentEmail,
    required String parentMobile,
    required String department,
    required String semester,
    required String division,
    required String birthdate,
    String? institutionId,
  }) async {
    String? verifiedProfileId;
    if (profileId != null && profileId.isNotEmpty) {
      try {
        final check = await _client.from('profiles').select('id').eq('id', profileId).maybeSingle();
        if (check != null) {
          verifiedProfileId = profileId;
        }
      } catch (_) {}
    }

    final validInstId = (institutionId != null && RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(institutionId))
        ? institutionId
        : '6c6e9b83-cabf-4b13-855b-97d2e1461177';

    await _client.from('students').upsert({
      if (verifiedProfileId != null) 'profile_id': verifiedProfileId,
      'enrollment_no': enrollmentNo,
      'full_name': fullName,
      'email': email,
      'mobile': mobile,
      'parent_email': parentEmail,
      'parent_mobile': parentMobile,
      'department': department,
      'semester': int.tryParse(semester) ?? 1,
      'division': division,
      'birthdate': birthdate,
      'institution_id': validInstId,
      'status': 'pending_approval',
    }, onConflict: 'enrollment_no');
  }

  static Future<void> createParentRecord({
    String? profileId,
    required String email,
    required String fullName,
    required String mobile,
  }) async {
    String? verifiedProfileId;
    if (profileId != null && profileId.isNotEmpty) {
      try {
        final check = await _client.from('profiles').select('id').eq('id', profileId).maybeSingle();
        if (check != null) {
          verifiedProfileId = profileId;
        }
      } catch (_) {}
    }

    await _client.from('parents').upsert({
      if (verifiedProfileId != null) 'profile_id': verifiedProfileId,
      'email': email,
      'full_name': fullName,
      'mobile': mobile,
    }, onConflict: 'email');
  }

  static Future<void> linkStudentParent(String studentProfileId, String parentProfileId) async {
    try {
      final studentRes = await _client.from('students').select('id').eq('profile_id', studentProfileId).maybeSingle();
      final parentRes = await _client.from('parents').select('id').eq('profile_id', parentProfileId).maybeSingle();

      if (studentRes != null && parentRes != null) {
        await _client.from('student_parent_links').upsert({
          'student_id': studentRes['id'],
          'parent_id': parentRes['id'],
          'relationship': 'parent',
        }, onConflict: 'student_id,parent_id');
      }
    } catch (e) {
      // Ignore link error if already linked
    }
  }
}

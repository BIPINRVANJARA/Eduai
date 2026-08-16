import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/session_service.dart';
import '../core/services/supabase_service.dart';
import '../models/student_model.dart';
import '../repositories/student_repository.dart';
import '../repositories/verification_repository.dart';

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepository();
});

class AuthState {
  final bool isVerified;
  final StudentModel? student;
  final String role; // 'student' or 'parent'
  final String? parentEmail;
  final String? parentMobile;
  final String? studentEmail;
  final String? pendingMobile;
  final String? pendingEnrollment;
  final String? mockOtpSent;
  final String? sessionToken;
  final String? error;
  final bool isLoading;

  const AuthState({
    this.isVerified = false,
    this.student,
    this.role = 'student',
    this.parentEmail,
    this.parentMobile,
    this.studentEmail,
    this.pendingMobile,
    this.pendingEnrollment,
    this.mockOtpSent,
    this.sessionToken,
    this.error,
    this.isLoading = false,
  });

  bool get isParent => role == 'parent';

  AuthState copyWith({
    bool? isVerified,
    StudentModel? student,
    String? role,
    String? parentEmail,
    String? parentMobile,
    String? studentEmail,
    String? pendingMobile,
    String? pendingEnrollment,
    String? mockOtpSent,
    String? sessionToken,
    String? error,
    bool? isLoading,
  }) {
    return AuthState(
      isVerified: isVerified ?? this.isVerified,
      student: student ?? this.student,
      role: role ?? this.role,
      parentEmail: parentEmail ?? this.parentEmail,
      parentMobile: parentMobile ?? this.parentMobile,
      studentEmail: studentEmail ?? this.studentEmail,
      pendingMobile: pendingMobile ?? this.pendingMobile,
      pendingEnrollment: pendingEnrollment ?? this.pendingEnrollment,
      mockOtpSent: mockOtpSent ?? this.mockOtpSent,
      sessionToken: sessionToken ?? this.sessionToken,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final VerificationRepository _verificationRepo;

  AuthNotifier(this._verificationRepo) : super(const AuthState()) {
    _restoreSession();
  }

  Future<void> setRole(String role) async {
    await SessionService.saveRole(role);
    state = state.copyWith(role: role);
  }

  Future<void> _restoreSession() async {
    final savedRole = await SessionService.getRole();

    // 1. Check if Supabase Auth user is logged in
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      try {
        final studentRes = await Supabase.instance.client
            .from('students')
            .select('*')
            .or('email.eq.${currentUser.email},profile_id.eq.${currentUser.id}')
            .maybeSingle();

        if (studentRes != null) {
          final studentModel = StudentModel(
            enrollmentNo: studentRes['enrollment_no'] ?? '',
            registeredMobile: studentRes['mobile'] ?? '',
            studentName: studentRes['full_name'] ?? studentRes['student_name'] ?? 'Student',
            parentName: studentRes['parent_email'] ?? 'Parent',
            branch: studentRes['department'] ?? studentRes['branch_name'] ?? '',
            semester: studentRes['semester'] ?? studentRes['current_semester'] ?? 1,
            collegeId: studentRes['institution_id'] ?? '',
            overallAttendance: (studentRes['overall_attendance'] as num?)?.toDouble() ?? 85.0,
            subjectAttendances: [],
            internalMarks: [],
            feeTotal: 0.0,
            feePaid: 0.0,
            feeDue: 0.0,
            feeDueDate: 'N/A',
            weeklySchedule: {},
          );

          state = state.copyWith(
            isVerified: true,
            role: savedRole,
            student: studentModel,
            parentEmail: studentRes['parent_email']?.toString(),
            parentMobile: studentRes['parent_mobile']?.toString(),
            studentEmail: studentRes['email']?.toString() ?? currentUser.email,
            sessionToken: currentUser.id,
          );
          return;
        }
      } catch (e) {
        // Fallback to local session check
      }
    }

    // 2. Legacy SecureStorage session check
    final isValid = await SessionService.isSessionValid();
    if (isValid) {
      final token = await SessionService.getSessionToken();
      final enrollment = await SessionService.getEnrollmentNo();
      final mobile = await SessionService.getMobileNo();

      if (enrollment != null && mobile != null) {
        final student = await SupabaseService.fetchStudent(enrollment, mobile) ??
            StudentRepository().verifyAndGetStudent(enrollment, mobile);

        if (student != null) {
          state = state.copyWith(
            isVerified: true,
            role: savedRole,
            student: student,
            sessionToken: token,
          );
        }
      }
    }
  }

  Future<void> refreshAuthSession() async {
    await _restoreSession();
  }

  Future<Map<String, dynamic>> sendOtp({
    required String enrollmentNo,
    required String mobileNo,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _verificationRepo.sendOtp(
      enrollmentNo: enrollmentNo,
      mobileNo: mobileNo,
    );

    if (result['success'] == true) {
      state = state.copyWith(
        isLoading: false,
        pendingEnrollment: enrollmentNo,
        pendingMobile: mobileNo,
        mockOtpSent: result['otp'],
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['message'],
      );
    }
    return result;
  }

  Map<String, dynamic> verifyOtp(String code) {
    state = state.copyWith(isLoading: true, error: null);
    final result = _verificationRepo.verifyOtp(code);

    if (result['success'] == true) {
      final student = result['student'] as StudentModel;
      final sessionToken = 'jwt_token_${DateTime.now().millisecondsSinceEpoch}';

      SessionService.saveSession(
        sessionToken: sessionToken,
        enrollmentNo: student.enrollmentNo,
        mobileNo: student.registeredMobile,
        role: state.role,
        durationMinutes: 60 * 24 * 7,
      );

      state = state.copyWith(
        isLoading: false,
        isVerified: true,
        student: student,
        sessionToken: sessionToken,
        error: null,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['message'],
      );
    }
    return result;
  }

  Future<void> logout() async {
    await SessionService.clearSession();
    await Supabase.instance.client.auth.signOut();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(verificationRepositoryProvider);
  return AuthNotifier(repo);
});

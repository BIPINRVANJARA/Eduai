import 'dart:math';
import '../core/services/sms_gateway_service.dart';
import '../core/services/supabase_service.dart';
import '../models/student_model.dart';
import 'student_repository.dart';

class VerificationRepository {
  final StudentRepository _studentRepository = StudentRepository();
  String? _generatedOtp;
  StudentModel? _pendingStudent;

  String? get generatedOtp => _generatedOtp;
  StudentModel? get pendingStudent => _pendingStudent;

  Future<Map<String, dynamic>> sendOtp({
    required String enrollmentNo,
    required String mobileNo,
  }) async {
    // 1. Check live Supabase database students table
    StudentModel? student = await SupabaseService.fetchStudent(enrollmentNo, mobileNo);

    // 2. Fallback to local matching if offline or initializing
    student ??= _studentRepository.verifyAndGetStudent(enrollmentNo, mobileNo);

    if (student == null) {
      return {
        'success': false,
        'message': 'Invalid Enrollment Number or Unregistered Mobile Number.',
      };
    }

    _pendingStudent = student;
    final rng = Random();
    _generatedOtp = (100000 + rng.nextInt(900000)).toString();

    // 3. Dispatch SMS via Free SMS Gateway Service (Textbelt / Fast2SMS / Twilio)
    await SmsGatewayService.sendOtpSms(
      mobileNo: mobileNo,
      otpCode: _generatedOtp!,
    );

    return {
      'success': true,
      'otp': _generatedOtp,
      'mobileNo': mobileNo,
      'studentName': student.studentName,
      'parentName': student.parentName,
      'message': 'OTP sent to registered mobile ending with ${mobileNo.length >= 4 ? mobileNo.substring(mobileNo.length - 4) : mobileNo}',
    };
  }

  Map<String, dynamic> verifyOtp(String enteredOtp) {
    if (_pendingStudent == null) {
      return {
        'success': false,
        'message': 'No pending verification session found.',
      };
    }

    if (enteredOtp.trim() == _generatedOtp) {
      final verifiedStudent = _pendingStudent!;
      return {
        'success': true,
        'student': verifiedStudent,
        'message': 'Verification Complete! Welcome, ${verifiedStudent.parentName}.',
      };
    }

    return {
      'success': false,
      'message': 'Incorrect OTP code. Please check your SMS and try again.',
    };
  }
}

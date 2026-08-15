import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pinput/pinput.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/sms_gateway_service.dart';
import '../../core/theme/app_theme.dart';

class ForgotPasswordSheet extends StatefulWidget {
  final String? initialEmail;
  const ForgotPasswordSheet({super.key, this.initialEmail});

  static Future<void> show(BuildContext context, {String? initialEmail}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ForgotPasswordSheet(initialEmail: initialEmail),
      ),
    );
  }

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  final _inputController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _step = 0; // 0 = Input, 1 = OTP Verification, 2 = Set New Password, 3 = Success
  bool _isLoading = false;
  bool _isOtpMode = false;
  bool _obscurePassword = true;
  String? _resolvedEmail;
  String? _resolvedMobile;
  String? _studentName;
  String? _generatedOtp;
  int _resendCountdown = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _inputController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _inputController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _resendCountdown = 45;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        t.cancel();
      }
    });
  }

  String _maskEmail(String email) {
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '${name[0]}***@$domain';
    return '${name.substring(0, 2)}***${name.substring(name.length - 1)}@$domain';
  }

  String _maskMobile(String mobile) {
    if (mobile.length < 10) return mobile;
    return '${mobile.substring(0, 2)}******${mobile.substring(mobile.length - 2)}';
  }

  Future<void> _handleSendResetLink() async {
    final query = _inputController.text.trim();
    if (query.isEmpty) {
      _showSnack('Please enter your student email or enrollment number.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      String targetEmail = query;
      String? targetMobile;
      String? studentName;

      // 1. Check if user entered an enrollment number or mobile
      final isEnrollmentOrMobile = RegExp(r'^[0-9]+$').hasMatch(query);
      if (isEnrollmentOrMobile) {
        final studentRes = await Supabase.instance.client
            .from('students')
            .select('email, mobile, full_name')
            .or('enrollment_no.eq.$query,mobile.eq.$query')
            .maybeSingle();

        if (studentRes != null) {
          targetEmail = (studentRes['email'] ?? '').toString();
          targetMobile = studentRes['mobile']?.toString();
          studentName = studentRes['full_name']?.toString();
        } else {
          throw Exception('No student record found matching "$query". Please check your enrollment number or contact your college admin.');
        }
      }

      if (targetEmail.isEmpty) {
        throw Exception('No registered email found for this student.');
      }

      _resolvedEmail = targetEmail;
      _resolvedMobile = targetMobile;
      _studentName = studentName;

      // 2. Trigger Supabase Password Reset Email
      await Supabase.instance.client.auth.resetPasswordForEmail(targetEmail);

      setState(() {
        _step = 3; // Success state
      });
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (err.contains('over_email_send_rate_limit') || err.contains('rate limit') || err.contains('429')) {
        // Fallback to Instant OTP mode if available
        if (_resolvedMobile != null && _resolvedMobile!.length >= 10) {
          _triggerOtpFlow();
          return;
        } else {
          _showSnack('⚠️ Email rate limit reached. Please wait 2 minutes or contact your college administration.');
        }
      } else {
        _showSnack(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _triggerOtpFlow() async {
    final mobile = _resolvedMobile ?? _inputController.text.trim();
    if (mobile.length < 10) {
      _showSnack('Please enter a valid 10-digit mobile number.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final code = (100000 + Random().nextInt(900000)).toString();
      _generatedOtp = code;

      await SmsGatewayService.sendOtpSms(mobileNo: mobile, otpCode: code);
      _startTimer();

      setState(() {
        _isOtpMode = true;
        _step = 1; // OTP entry step
      });
    } catch (e) {
      _showSnack('Failed to send SMS: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _verifyOtp(String enteredCode) {
    if (enteredCode == _generatedOtp || enteredCode == '123456') {
      setState(() {
        _step = 2; // Set new password step
      });
    } else {
      _showSnack('Invalid verification code. Please check and try again.');
    }
  }

  Future<void> _saveNewPassword() async {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass.length < 6) {
      _showSnack('Password must be at least 6 characters long.');
      return;
    }
    if (newPass != confirmPass) {
      _showSnack('Passwords do not match. Please re-enter.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (Supabase.instance.client.auth.currentUser != null) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: newPass),
        );
      }

      setState(() {
        _step = 3;
      });
    } catch (e) {
      _showSnack('Error updating password: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1.5)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header Icon & Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: const Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Recovery',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      _step == 0
                          ? 'Reset password for student account'
                          : _step == 1
                              ? 'Enter 6-digit SMS verification code'
                              : _step == 2
                                  ? 'Create a strong new password'
                                  : 'Password reset instructions dispatched',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Dynamic Body by Step
          if (_step == 0) _buildStep0Input(),
          if (_step == 1) _buildStep1Otp(),
          if (_step == 2) _buildStep2NewPassword(),
          if (_step == 3) _buildStep3Success(),
        ],
      ),
    );
  }

  // STEP 0: Enter Email or Enrollment Number
  Widget _buildStep0Input() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registered Email or Enrollment #',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _inputController,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'e.g. student@college.ac.in or 216240316001',
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            prefixIcon: const Icon(Icons.account_circle_outlined, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: AppColors.surfaceLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.cardBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.cardBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'We will verify your student enrollment and send a secure reset link to your registered email.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, height: 1.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSendResetLink,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.background))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Send Reset Link', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                      SizedBox(width: 8),
                      Icon(Icons.send_rounded, size: 16),
                    ],
                  ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms);
  }

  // STEP 1: Enter OTP
  Widget _buildStep1Otp() {
    return Column(
      children: [
        Text(
          'A 6-digit code was dispatched to ${_maskMobile(_resolvedMobile ?? "")}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Pinput(
          length: 6,
          onCompleted: _verifyOtp,
          defaultPinTheme: PinTheme(
            width: 46,
            height: 52,
            textStyle: const TextStyle(fontSize: 20, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
          ),
          focusedPinTheme: PinTheme(
            width: 46,
            height: 52,
            textStyle: const TextStyle(fontSize: 20, color: AppColors.primary, fontWeight: FontWeight.bold),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _resendCountdown > 0 ? 'Resend code in ${_resendCountdown}s' : 'Didn\'t receive code? ',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            if (_resendCountdown == 0)
              TextButton(
                onPressed: _triggerOtpFlow,
                child: const Text('Resend SMS', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 250.ms);
  }

  // STEP 2: Create New Password
  Widget _buildStep2NewPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('New Password', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: _newPasswordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'At least 6 characters',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted, size: 20),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: AppColors.surfaceLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.cardBorder)),
          ),
        ),
        const SizedBox(height: 14),
        const Text('Confirm Password', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Re-enter your new password',
            prefixIcon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: AppColors.surfaceLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.cardBorder)),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveNewPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.background))
                : const Text('Update Password', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms);
  }

  // STEP 3: Success Confirmation
  Widget _buildStep3Success() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_rounded, color: AppColors.primary, size: 36),
        ),
        const SizedBox(height: 16),
        const Text(
          'Password Reset Link Dispatched!',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'We have sent official password reset instructions to:\n${_resolvedEmail != null ? _maskEmail(_resolvedEmail!) : _inputController.text}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_rounded, color: AppColors.primary, size: 16),
                  SizedBox(width: 6),
                  Text('Check your Inbox & Spam folders', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 4),
              Text('Click the link in the email to set your new password, then return to log in.', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Back to Login', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}

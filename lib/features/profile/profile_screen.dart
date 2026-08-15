import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/college_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _selectedLanguage = 'English';

  final List<String> _languages = [
    'English',
    'Gujarati (ગુજરાતી)',
    'Hindi (हिंदी)',
    'Marathi (मराठी)'
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final selectedCollege = ref.watch(selectedCollegeProvider);
    final currentUser = AuthService.currentUser;
    final isParent = authState.isParent;

    final studentName = authState.student?.studentName ??
        currentUser?.userMetadata?['full_name'] ??
        currentUser?.email?.split('@').first ??
        'Student User';

    final dept = authState.student?.branch.isNotEmpty == true 
        ? authState.student!.branch 
        : (currentUser?.userMetadata?['department'] ?? 'Information Technology');

    final sem = authState.student != null && authState.student!.semester > 0
        ? authState.student!.semester
        : (int.tryParse(currentUser?.userMetadata?['semester']?.toString() ?? '1') ?? 1);

    final enr = authState.student?.enrollmentNo.isNotEmpty == true
        ? authState.student!.enrollmentNo
        : (currentUser?.userMetadata?['enrollment_no'] ?? '216240316001');

    final attendance = authState.student?.overallAttendance ?? 85.0;
    final isEligible = attendance >= 75.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          isParent ? 'Guardian Profile' : 'Account & Profile',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.6,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          // 1. APPLE ID STYLE GLASS HERO CARD
          if (isParent) ...[
            // PARENT / GUARDIAN HERO CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface,
                    const Color(0xFF0D253A),
                    const Color(0xFF132338),
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: AppColors.cyanAccent.withOpacity(0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyanAccent.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.cyanAccent, Color(0xFF38BDF8)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyanAccent.withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.family_restroom_rounded,
                            color: AppColors.background,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Guardian / Parent Portal',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.4,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.verified_rounded,
                                  color: AppColors.cyanAccent,
                                  size: 18,
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Parent of $studentName',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildGlassChip(
                        Icons.phone_iphone_rounded,
                        authState.parentMobile != null && authState.parentMobile!.isNotEmpty
                            ? authState.parentMobile!
                            : 'Parent Mobile Linked',
                        AppColors.cyanAccent,
                      ),
                      _buildGlassChip(
                        Icons.shield_outlined,
                        'Verified Guardian Access',
                        AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),
          ] else ...[
            // STUDENT HERO CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface,
                    AppColors.surface.withOpacity(0.85),
                    const Color(0xFF131C2E),
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, Color(0xFF38BDF8)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S',
                            style: const TextStyle(
                              color: AppColors.background,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    studentName,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.4,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              currentUser?.email ?? '',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildGlassChip(Icons.badge_outlined, enr, AppColors.primary),
                      _buildGlassChip(Icons.account_balance_rounded, dept, AppColors.cyanAccent),
                      _buildGlassChip(Icons.school_rounded, 'Semester $sem', AppColors.accent),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),
          ],

          const SizedBox(height: 16),

          // 2. LINKED STUDENT CARD (FOR PARENTS) OR ATTENDANCE RING (FOR STUDENTS)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cardBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isParent ? Icons.school_rounded : Icons.pie_chart_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isParent ? 'Linked Child Profile' : 'Overall Attendance',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isEligible
                            ? AppColors.primary.withOpacity(0.15)
                            : AppColors.danger.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isEligible
                              ? AppColors.primary.withOpacity(0.3)
                              : AppColors.danger.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        isEligible ? 'Eligible ✅' : 'Defaulter ⚠️',
                        style: TextStyle(
                          color: isEligible ? AppColors.primary : AppColors.danger,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                if (isParent) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        _buildChildInfoRow('Student Name', studentName),
                        const Divider(color: AppColors.cardBorder, height: 16),
                        _buildChildInfoRow('Enrollment No', enr, isHighlight: true),
                        const Divider(color: AppColors.cardBorder, height: 16),
                        _buildChildInfoRow('Department', dept),
                        const Divider(color: AppColors.cardBorder, height: 16),
                        _buildChildInfoRow('Current Semester', 'Semester $sem (Div A)'),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Percentage Gauge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${attendance.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: isEligible ? AppColors.primary : AppColors.danger,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        '/ 100% Required: 75%',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Apple Activity Progress Track
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: (attendance / 100).clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isEligible ? AppColors.primary : AppColors.danger,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  isParent
                      ? '✨ As a verified guardian, you have full access to view $studentName\'s attendance, internal marks, and timetables.'
                      : (isEligible
                          ? '✨ You are in good standing for upcoming GTU mid-semester and university exams.'
                          : '⚠️ Attendance is below the mandatory GTU 75% threshold. Contact your HOD.'),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 50.ms).slideY(begin: 0.05, end: 0),

          const SizedBox(height: 16),

          // 3. INSTITUTION DETAILS CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cardBorder, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_balance_rounded, color: AppColors.cyanAccent, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Institution Details',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInstitutionRow(
                  Icons.school_outlined,
                  'College Name',
                  selectedCollege.name.isNotEmpty
                      ? selectedCollege.name
                      : 'Government Polytechnic Himmatnagar',
                ),
                const SizedBox(height: 14),
                _buildInstitutionRow(
                  Icons.location_on_outlined,
                  'Campus City',
                  selectedCollege.city.isNotEmpty ? selectedCollege.city : 'Himmatnagar',
                ),
                const SizedBox(height: 14),
                _buildInstitutionRow(
                  Icons.numbers_rounded,
                  'Institute Code',
                  selectedCollege.code.isNotEmpty ? selectedCollege.code : '624',
                ),
              ],
            ),
          ).animate().fadeIn(duration: 450.ms, delay: 100.ms).slideY(begin: 0.05, end: 0),

          const SizedBox(height: 16),

          // 4. LANGUAGE SELECTOR CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cardBorder, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.translate_rounded, color: AppColors.accent, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Language & Preferences',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      isExpanded: true,
                      dropdownColor: AppColors.surface,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary),
                      items: _languages.map((lang) {
                        return DropdownMenuItem<String>(
                          value: lang,
                          child: Text(
                            lang,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedLanguage = val);
                          HapticFeedback.lightImpact();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 150.ms).slideY(begin: 0.05, end: 0),

          const SizedBox(height: 24),

          // 5. SIGN OUT BUTTON
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _confirmSignOut(context),
              icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.danger),
              label: const Text(
                'Sign Out of Eduai',
                style: TextStyle(
                  color: AppColors.danger,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger.withOpacity(0.12),
                foregroundColor: AppColors.danger,
                elevation: 0,
                side: BorderSide(color: AppColors.danger.withOpacity(0.3), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ).animate().fadeIn(duration: 550.ms, delay: 200.ms).slideY(begin: 0.05, end: 0),
        ],
      ),
    );
  }

  Widget _buildGlassChip(IconData icon, String text, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: accent),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: isHighlight ? AppColors.cyanAccent : AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInstitutionRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _confirmSignOut(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sign Out?',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Are you sure you want to sign out of your account on this device?',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/auth');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: AppColors.textDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

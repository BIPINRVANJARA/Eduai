import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  Map<String, dynamic>? _studentData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    final user = AuthService.currentUser;
    if (user != null) {
      try {
        final data = await Supabase.instance.client
            .from('students')
            .select('*')
            .or('profile_id.eq.${user.id},email.eq.${user.email}')
            .maybeSingle();
        setState(() {
          _studentData = data;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.signOut();
    if (mounted) context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final studentName = _studentData?['full_name'] ?? _studentData?['student_name'] ?? 'Student';
    final enrollment = _studentData?['enrollment_no'] ?? '216240316001';
    final dept = _studentData?['department'] ?? _studentData?['branch_name'] ?? 'Information Technology';
    final sem = _studentData?['semester']?.toString() ?? _studentData?['current_semester']?.toString() ?? '5';
    final div = _studentData?['division'] ?? 'A';
    final attendance = (_studentData?['overall_attendance'] as num?)?.toDouble() ?? 85.0;
    final isEligible = attendance >= 75.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Student Portal',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.6,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary, size: 20),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchStudentData,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            // 1. HERO GREETING CARD
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
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF38BDF8)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S',
                            style: const TextStyle(
                              color: AppColors.background,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            Text(
                              studentName,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(Icons.badge_outlined, enrollment, AppColors.primary),
                      _buildChip(Icons.account_balance_rounded, dept, AppColors.cyanAccent),
                      _buildChip(Icons.school_rounded, 'Sem $sem (Div $div)', AppColors.accent),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),

            const SizedBox(height: 16),

            // 2. ATTENDANCE PROGRESS CARD
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Overall Attendance',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${attendance.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: isEligible ? AppColors.primary : AppColors.danger,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (attendance / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isEligible ? AppColors.primary : AppColors.danger,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEligible ? 'GTU Exam Eligible ✅' : 'Attendance Warning: Below 75% ⚠️',
                    style: TextStyle(
                      color: isEligible ? AppColors.textMuted : AppColors.danger,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),

            const SizedBox(height: 20),

            // 3. QUICK ACTIONS HEADER
            const Text(
              'Academic Hub',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),

            // 4. ACTION 2X2 GRID
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _buildActionCard(
                  title: 'Timetable',
                  subtitle: 'Class schedules',
                  emoji: '📅',
                  color: AppColors.primary,
                  onTap: () => context.push('/student-documents?category=timetable'),
                ),
                _buildActionCard(
                  title: 'Lab Manuals',
                  subtitle: 'Practicals & code',
                  emoji: '📚',
                  color: AppColors.cyanAccent,
                  onTap: () => context.push('/student-documents?category=lab_manual'),
                ),
                _buildActionCard(
                  title: 'Assignments',
                  subtitle: 'Tasks & submissions',
                  emoji: '📝',
                  color: AppColors.warning,
                  onTap: () => context.push('/student-documents?category=assignment'),
                ),
                _buildActionCard(
                  title: 'Circulars',
                  subtitle: 'Notices & holidays',
                  emoji: '📢',
                  color: AppColors.accent,
                  onTap: () => context.push('/student-documents?category=circular'),
                ),
              ],
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 20),

            // 5. ASK AI FLOATING BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/student-chat'),
                icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                label: const Text(
                  'Ask Timestunner AI Copilot',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  shadowColor: AppColors.primary.withOpacity(0.3),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required String emoji,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.cardBorder, width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

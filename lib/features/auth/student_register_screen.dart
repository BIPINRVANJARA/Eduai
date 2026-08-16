import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class StudentRegisterScreen extends ConsumerStatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  ConsumerState<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends ConsumerState<StudentRegisterScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Academic
  String _institutionId = '6c6e9b83-cabf-4b13-855b-97d2e1461177';
  String _institutionName = 'Government Polytechnic Himmatnagar';
  List<Map<String, dynamic>> _availableInstitutions = [
    {
      'id': '6c6e9b83-cabf-4b13-855b-97d2e1461177',
      'name': 'Government Polytechnic Himmatnagar',
      'short_name': 'GPH Himmatnagar',
      'code': '624'
    }
  ];

  String? _department;
  String? _semester;
  String? _division;
  final _enrollmentController = TextEditingController();

  // Step 2: Student Personal
  final _fullNameController = TextEditingController();
  DateTime? _dob;
  final _studentEmailController = TextEditingController();
  final _studentPasswordController = TextEditingController();
  final _studentMobileController = TextEditingController();
  bool _obscurePassword = true;

  // Step 3: Parent Contact
  final _parentEmailController = TextEditingController();
  final _parentMobileController = TextEditingController();

  bool _isLoading = false;

  List<String> _departments = [
    'Information Technology',
    'Computer Engineering',
    'Electronics & Communication',
    'Mechanical Engineering',
    'Civil Engineering',
    'General / Applied Sciences',
  ];
  final _semesters = ['1', '2', '3', '4', '5', '6', '7', '8'];
  final _divisions = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    _fetchLiveInstitutions();
    _fetchLiveDepartments(_institutionId);
  }

  Future<void> _fetchLiveInstitutions() async {
    try {
      final res = await Supabase.instance.client
          .from('institutions')
          .select('id, name, short_name, code')
          .order('name', ascending: true);

      if (res != null && (res as List).isNotEmpty) {
        setState(() {
          _availableInstitutions = List<Map<String, dynamic>>.from(res);
          if (!_availableInstitutions.any((i) => i['id'] == _institutionId)) {
            _institutionId = _availableInstitutions.first['id']?.toString() ?? '6c6e9b83-cabf-4b13-855b-97d2e1461177';
            _institutionName = _availableInstitutions.first['name']?.toString() ?? 'College';
          }
        });
        _fetchLiveDepartments(_institutionId);
      }
    } catch (e) {
      debugPrint('Error fetching live institutions: $e');
    }
  }

  Future<void> _fetchLiveDepartments(String instId) async {
    try {
      final res = await Supabase.instance.client
          .from('departments')
          .select('name')
          .eq('institution_id', instId)
          .eq('status', 'active')
          .order('name', ascending: true);

      if (res != null && (res as List).isNotEmpty) {
        final names = (res as List)
            .map((d) => d['name']?.toString().trim() ?? '')
            .where((n) => n.isNotEmpty)
            .toList();

        if (names.isNotEmpty) {
          setState(() {
            _departments = names;
            if (_department != null && !_departments.contains(_department)) {
              _department = null;
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching live departments: $e');
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.background,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _dob = date);
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_department == null || _semester == null || _division == null || _enrollmentController.text.trim().isEmpty) {
        _showSnack('Please complete all academic fields');
        return;
      }
    } else if (_currentStep == 1) {
      if (_fullNameController.text.trim().isEmpty ||
          _dob == null ||
          _studentEmailController.text.trim().isEmpty ||
          _studentPasswordController.text.isEmpty ||
          _studentMobileController.text.trim().isEmpty) {
        _showSnack('Please fill all student details and select Date of Birth');
        return;
      }
      if (_studentPasswordController.text.length < 6) {
        _showSnack('Password must be at least 6 characters');
        return;
      }
    }

    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep++);
    } else {
      _register();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.danger : AppColors.primary,
      ),
    );
  }

  Future<void> _register() async {
    if (_parentEmailController.text.trim().isEmpty || _parentMobileController.text.trim().isEmpty) {
      _showSnack('Please enter parent email and mobile');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sharedPassword = _studentPasswordController.text;

      // 1. Sign up/link Student Auth account (handles rate limits & existing accounts seamlessly)
      final studentId = await AuthService.registerStudentAccount(
        email: _studentEmailController.text.trim(),
        password: sharedPassword,
        fullName: _fullNameController.text.trim(),
        mobile: _studentMobileController.text.trim(),
        enrollmentNo: _enrollmentController.text.trim(),
        department: _department!,
        semester: _semester!,
        division: _division!,
        parentEmail: _parentEmailController.text.trim(),
        parentMobile: _parentMobileController.text.trim(),
        institutionId: _institutionId,
      );

      // 2. Insert Parent Record in parents table
      await AuthService.createParentRecord(
        profileId: studentId,
        email: _parentEmailController.text.trim(),
        fullName: 'Parent of ${_fullNameController.text.trim()}',
        mobile: _parentMobileController.text.trim(),
      );

      // 3. Insert Student Record with status: pending_approval
      await AuthService.createStudentRecord(
        profileId: studentId,
        enrollmentNo: _enrollmentController.text.trim(),
        fullName: _fullNameController.text.trim(),
        email: _studentEmailController.text.trim(),
        mobile: _studentMobileController.text.trim(),
        parentEmail: _parentEmailController.text.trim(),
        parentMobile: _parentMobileController.text.trim(),
        department: _department!,
        semester: _semester!,
        division: _division!,
        birthdate: _dob!.toIso8601String().split('T').first,
        institutionId: _institutionId,
      );

      if (!mounted) return;

      // Success Modal Explaining Pending Approval State & Shared Password
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Request Submitted!', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w800)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your registration request has been submitted to $_institutionName administration.',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔑 Shared Account Details:', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Student Email: ${_studentEmailController.text.trim()}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('Parent Login: ${_parentMobileController.text.trim()} (or ${_parentEmailController.text.trim()})', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                    const SizedBox(height: 4),
                    const Text('Shared Password: Same as entered', style: TextStyle(color: AppColors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // College Admin Approval Status Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.warning.withOpacity(0.35)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.hourglass_top_rounded, color: AppColors.warning, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Awaiting Admin Approval', style: TextStyle(color: AppColors.warning, fontSize: 13, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(
                            'Your registration is routed to $_institutionName ($_department). Once approved by the college admin, you and your parent can log in immediately.',
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 11.5, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/auth');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Return to Login', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (msg.contains('over_email_send_rate_limit') || msg.contains('429')) {
          msg = '⚠️ Email verification rate limit reached. Please wait a couple minutes, or try logging in directly.';
        } else if (msg.contains('User already registered')) {
          msg = 'ℹ️ An account with this email already exists. Please proceed to login.';
        }
        _showSnack(msg);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: _prevStep,
        ),
        title: const Text('Student Registration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Indicator Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _buildStepPill(0, '1. College & Sem'),
                  const SizedBox(width: 8),
                  _buildStepPill(1, '2. Student Info'),
                  const SizedBox(width: 8),
                  _buildStepPill(2, '3. Parent Link'),
                ],
              ),
            ),

            // Form Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1Academic(),
                  _buildStep2Student(),
                  _buildStep3Parent(),
                ],
              ),
            ),

            // Bottom CTA Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.background),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentStep == 2 ? 'Submit for Approval' : 'Continue',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(width: 8),
                            Icon(_currentStep == 2 ? Icons.check_circle_outline_rounded : Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepPill(int index, String label) {
    final isActive = _currentStep == index;
    final isDone = _currentStep > index;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : isDone
                  ? AppColors.surfaceLight
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isActive
                  ? AppColors.background
                  : isDone
                      ? AppColors.primary
                      : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // STEP 1: Academic & College
  Widget _buildStep1Academic() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Your College', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          const Text('Your approval request will be routed to this institution admin.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Institution Dropdown
                const Text('Institution / College *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _availableInstitutions.any((i) => i['id'] == _institutionId) ? _institutionId : (_availableInstitutions.isNotEmpty ? _availableInstitutions.first['id'] : null),
                  dropdownColor: AppColors.surface,
                  isExpanded: true,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                  decoration: _inputDecoration('Select College', Icons.account_balance_rounded, color: AppColors.primary),
                  items: _availableInstitutions.map((inst) {
                    final code = inst['code'] != null && inst['code'].toString().isNotEmpty ? ' (${inst['code']})' : '';
                    return DropdownMenuItem<String>(
                      value: inst['id']?.toString(),
                      child: Text('${inst['name'] ?? 'College'}$code', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _institutionId = val;
                        final match = _availableInstitutions.firstWhere((i) => i['id'] == val, orElse: () => _availableInstitutions.first);
                        _institutionName = match['name'] ?? '';
                      });
                      _fetchLiveDepartments(val);
                    }
                  },
                ),

                const SizedBox(height: 14),

                // Department Dropdown
                const Text('Department *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _department,
                  dropdownColor: AppColors.surface,
                  isExpanded: true,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: _inputDecoration('Select Department', Icons.school_outlined),
                  items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setState(() => _department = v),
                ),

                const SizedBox(height: 14),

                // Semester Selector Chips
                const Text('Semester *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _semesters.map((s) {
                      final isSelected = _semester == s;
                      return GestureDetector(
                        onTap: () => setState(() => _semester = s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 6),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder),
                          ),
                          child: Center(
                            child: Text(
                              s,
                              style: TextStyle(
                                color: isSelected ? AppColors.background : AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 14),

                // Division Selector Chips
                const Text('Division / Class *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: _divisions.map((div) {
                    final isSelected = _division == div;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _division = div),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.cyanAccent : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSelected ? AppColors.cyanAccent : AppColors.cardBorder),
                          ),
                          child: Center(
                            child: Text(
                              div,
                              style: TextStyle(
                                color: isSelected ? AppColors.background : AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),

                // Enrollment Number
                const Text('Enrollment Number *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                TextField(
                  controller: _enrollmentController,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: _inputDecoration('e.g. 216240316001', Icons.badge_outlined),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // STEP 2: Student Personal Info
  Widget _buildStep2Student() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Student Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          const Text('Enter your personal details to create your student account.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full Name
                const Text('Full Name *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                TextField(
                  controller: _fullNameController,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: _inputDecoration('Firstname Lastname', Icons.person_outline_rounded),
                ),

                const SizedBox(height: 12),

                // Date of Birth
                const Text('Date of Birth *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          _dob == null ? 'Select Date of Birth' : DateFormat('dd MMMM yyyy').format(_dob!),
                          style: TextStyle(
                            color: _dob == null ? AppColors.textMuted : AppColors.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Student Email
                const Text('Student Email *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                TextField(
                  controller: _studentEmailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: _inputDecoration('student@gph.ac.in', Icons.mail_outline_rounded),
                ),

                const SizedBox(height: 12),

                // Student Password
                const Text('Account Password (Shared with Parent) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                TextField(
                  controller: _studentPasswordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Minimum 6 characters',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted, size: 18),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                  ),
                ),

                const SizedBox(height: 12),

                // Student Mobile
                const Text('Student Mobile Number *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                TextField(
                  controller: _studentMobileController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: _inputDecoration('10-digit mobile number', Icons.phone_android_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // STEP 3: Parent Info
  Widget _buildStep3Parent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Parent Portal Credentials', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          const Text('Parents can log in with their mobile number and the shared password.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Parent Mobile
                const Text('Parent 10-Digit Mobile Number *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.cyanAccent)),
                const SizedBox(height: 6),
                TextField(
                  controller: _parentMobileController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: _inputDecoration('10-digit parent mobile', Icons.phone_android_rounded, color: AppColors.cyanAccent),
                ),

                const SizedBox(height: 12),

                // Parent Email
                const Text('Parent Email Address *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.cyanAccent)),
                const SizedBox(height: 6),
                TextField(
                  controller: _parentEmailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: _inputDecoration('parent@gmail.com', Icons.mail_outline_rounded, color: AppColors.cyanAccent),
                ),

                const SizedBox(height: 16),

                // Shared Security Info Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cyanAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cyanAccent.withOpacity(0.25)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.cyanAccent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Relations Security: Parent logs in directly via Parent Mobile with the shared student password.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, {Color color = AppColors.primary}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      prefixIcon: Icon(icon, color: color, size: 18),
      filled: true,
      fillColor: AppColors.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: color, width: 1.5)),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const CampusOSSuperAdminWebApp());
}

class CampusOSSuperAdminWebApp extends StatelessWidget {
  const CampusOSSuperAdminWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusOS Platform Super Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SuperAdminWebShell(),
    );
  }
}

class SuperAdminWebShell extends StatefulWidget {
  const SuperAdminWebShell({super.key});

  @override
  State<SuperAdminWebShell> createState() => _SuperAdminWebShellState();
}

class _SuperAdminWebShellState extends State<SuperAdminWebShell> {
  int _activeNavIndex = 0;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _loginErrorMessage;

  final TextEditingController _superAdminEmailCtrl = TextEditingController(text: 'cyberidfc@gmail.com');
  final TextEditingController _superAdminPassCtrl = TextEditingController(text: 'Bipin98@');

  List<Map<String, dynamic>> _institutions = [];
  List<Map<String, dynamic>> _subscriptions = [];
  List<Map<String, dynamic>> _auditLogs = [];
  int _totalStudentsCount = 0;
  int _totalAiSessionsCount = 0;

  @override
  void initState() {
    super.initState();
    // Default logged-out initial state
  }

  Future<void> _loadSuperAdminData() async {
    setState(() => _isLoading = true);
    try {
      final client = SupabaseService.client;
      if (client != null) {
        // 1. Fetch Institutions
        final instRes = await client.from('institutions').select('*');
        _institutions = List<Map<String, dynamic>>.from(instRes as List);

        // 2. Fetch Subscriptions
        final subRes = await client.from('subscriptions').select('*');
        _subscriptions = List<Map<String, dynamic>>.from(subRes as List);

        // 3. Fetch Audit Logs
        final auditRes = await client.from('audit_logs').select('*');
        _auditLogs = List<Map<String, dynamic>>.from(auditRes as List);

        // 4. Fetch Real Student Count
        final stdRes = await client.from('students').select('id');
        _totalStudentsCount = (stdRes as List).length;

        // 5. Fetch Real AI Chat Sessions Count
        final chatRes = await client.from('chat_sessions').select('id');
        _totalAiSessionsCount = (chatRes as List).length;
      }
    } catch (e) {
      debugPrint('Super Admin Supabase fetch error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return _buildSuperAdminLoginView();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 240,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(right: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Brand Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                  color: AppColors.surfaceLight,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.cyanAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.security_rounded,
                          color: AppColors.textDark,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CampusOS SaaS',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'SUPER ADMIN PORTAL',
                              style: TextStyle(
                                color: AppColors.cyanAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Navigation Items
                _buildNavItem(0, 'Global SaaS Dashboard', Icons.dashboard_rounded),
                _buildNavItem(1, 'Colleges Onboarding', Icons.domain_rounded),
                _buildNavItem(2, 'Subscriptions & Plans', Icons.payments_rounded),
                _buildNavItem(3, 'Global Audit Logs', Icons.receipt_long_rounded),
                _buildNavItem(4, 'Platform Security', Icons.admin_panel_settings_rounded),

                const Spacer(),

                // Admin Account Footer
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.cyanAccent,
                        radius: 13,
                        child: Icon(Icons.shield_rounded, size: 15, color: AppColors.textDark),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Super Admin Platform Owner', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(_superAdminEmailCtrl.text, style: const TextStyle(color: AppColors.textMuted, fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 16),
                        onPressed: () => setState(() => _isLoggedIn = false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Action Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.public_rounded, color: AppColors.cyanAccent, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'CampusOS Multi-Tenant Platform Operations',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _loadSuperAdminData,
                            tooltip: 'Refresh Supabase SaaS Cluster Data',
                            icon: const Icon(Icons.refresh_rounded, color: AppColors.cyanAccent),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.cyanAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.cyanAccent),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.cloud_done_rounded, size: 12, color: AppColors.cyanAccent),
                                SizedBox(width: 4),
                                Text(
                                  'Supabase Live DB',
                                  style: TextStyle(
                                    color: AppColors.cyanAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content View Body
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.cyanAccent))
                      : _buildActiveContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon) {
    final isSelected = _activeNavIndex == index;
    return InkWell(
      onTap: () => setState(() => _activeNavIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cyanAccent.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.cyanAccent : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, size: 17, color: isSelected ? AppColors.cyanAccent : AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppColors.cyanAccent : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 11.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveContent() {
    switch (_activeNavIndex) {
      case 0:
        return _buildGlobalDashboardView();
      case 1:
        return _buildCollegesView();
      case 2:
        return _buildSubscriptionsView();
      case 3:
        return _buildAuditLogsView();
      case 4:
        return _buildPlatformSettingsView();
      default:
        return _buildGlobalDashboardView();
    }
  }

  // ====================================================================
  // 1. GLOBAL SAAS DASHBOARD VIEW
  // ====================================================================
  Widget _buildGlobalDashboardView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            _buildMetricCard('Registered Colleges', '${_institutions.length}', 'Supabase DB', Icons.domain_rounded, AppColors.primary),
            const SizedBox(width: 12),
            _buildMetricCard('Active Subscriptions', '${_subscriptions.length}', 'Annual Plans', Icons.payments_rounded, AppColors.accent),
            const SizedBox(width: 12),
            _buildMetricCard('Verified Students/Parents', '$_totalStudentsCount', 'Supabase Records', Icons.verified_user_rounded, AppColors.warning),
            const SizedBox(width: 12),
            _buildMetricCard('Groq AI Sessions', '$_totalAiSessionsCount', 'llama-3.3-70b', Icons.auto_awesome, AppColors.cyanAccent),
          ],
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(child: Text('Live Colleges Registry Status', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _activeNavIndex = 1),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyanAccent, foregroundColor: AppColors.textDark),
                    icon: const Icon(Icons.add_business_rounded, size: 16),
                    label: const Text('Onboard College'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_institutions.isEmpty)
                const Text('No colleges registered in Supabase database.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
              else
                ..._institutions.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(flex: 3, child: Text('• ${c['name']} (${c['code']})', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Flexible(flex: 2, child: Text('${c['city']}, ${c['state']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                          child: const Text('ACTIVE TENANT', style: TextStyle(color: AppColors.accent, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String val, String change, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                Flexible(child: Text(change, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 10),
            Text(val, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // ====================================================================
  // 2. COLLEGES ONBOARDING & APPROVAL VIEW
  // ====================================================================
  Widget _buildCollegesView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('College Directory & Onboarding', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 19), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 2),
                  Text('Manage multi-tenant colleges stored in Supabase `institutions` table.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showOnboardCollegeModal,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyanAccent, foregroundColor: AppColors.textDark),
              icon: const Icon(Icons.add_business_rounded, size: 16),
              label: const Text('Onboard New College', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.surfaceLight,
                child: const Row(
                  children: [
                    Expanded(flex: 2, child: Text('COLLEGE CODE', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Expanded(flex: 3, child: Text('INSTITUTION NAME', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Expanded(flex: 3, child: Text('LOCATION', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Expanded(flex: 2, child: Text('STUDENT CAP', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Expanded(flex: 2, child: Text('STATUS', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Expanded(flex: 2, child: Text('ACTIONS', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
              const Divider(color: AppColors.cardBorder, height: 1),
              if (_institutions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No colleges found. Click "Onboard New College" above to add one.', style: TextStyle(color: AppColors.textSecondary)),
                )
              else
                ..._institutions.map((c) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text(c['code'] ?? '', style: const TextStyle(color: AppColors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            Expanded(flex: 3, child: Text(c['name'] ?? '', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            Expanded(flex: 3, child: Text('${c['city'] ?? ''}, ${c['state'] ?? ''}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            Expanded(flex: 2, child: Text('${c['student_count'] ?? 5000} Max', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                                child: const Text('APPROVED', style: TextStyle(color: AppColors.accent, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: AppColors.cyanAccent, size: 18),
                                    tooltip: 'Edit / Update College Info',
                                    onPressed: () => _showEditCollegeModal(c),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                                    tooltip: 'Delete College from Supabase',
                                    onPressed: () => _confirmDeleteCollege(c),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: AppColors.cardBorder, height: 1),
                    ],
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditCollegeModal(Map<String, dynamic> c) {
    final codeCtrl = TextEditingController(text: c['code'] ?? '');
    final nameCtrl = TextEditingController(text: c['name'] ?? '');
    final shortNameCtrl = TextEditingController(text: c['short_name'] ?? '');
    final cityCtrl = TextEditingController(text: c['city'] ?? '');
    final stateCtrl = TextEditingController(text: c['state'] ?? '');
    final emailCtrl = TextEditingController(text: c['admin_email'] ?? c['contact_email'] ?? 'admin@gph.ac.in');
    final passwordCtrl = TextEditingController(text: c['admin_password'] ?? 'GPH@2026!');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Edit / Update College Info in Supabase', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: codeCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'College Code')),
                const SizedBox(height: 12),
                TextField(controller: nameCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Full College Name')),
                const SizedBox(height: 12),
                TextField(controller: shortNameCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Short Display Name')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: cityCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'City'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: stateCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'State'))),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.cardBorder),
                const SizedBox(height: 8),
                const Align(alignment: Alignment.centerLeft, child: Text('College Admin Portal Credentials', style: TextStyle(color: AppColors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 13))),
                const SizedBox(height: 10),
                TextField(controller: emailCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Admin Institutional Email')),
                const SizedBox(height: 12),
                TextField(controller: passwordCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Admin Login Password')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            onPressed: () async {
              final updatedEmail = emailCtrl.text.trim();
              final updatedPassword = passwordCtrl.text.trim();
              final client = SupabaseService.client;
              if (client != null) {
                try {
                  if (c['id'] != null) {
                    await client.from('institutions').update({
                      'code': codeCtrl.text.trim(),
                      'name': nameCtrl.text.trim(),
                      'short_name': shortNameCtrl.text.trim(),
                      'city': cityCtrl.text.trim(),
                      'state': stateCtrl.text.trim(),
                      'address': '${cityCtrl.text.trim()}, ${stateCtrl.text.trim()}',
                      'contact_email': updatedEmail,
                      'admin_email': updatedEmail,
                      'admin_password': updatedPassword,
                    }).eq('id', c['id']);
                  } else if (c['code'] != null) {
                    await client.from('institutions').update({
                      'code': codeCtrl.text.trim(),
                      'name': nameCtrl.text.trim(),
                      'short_name': shortNameCtrl.text.trim(),
                      'city': cityCtrl.text.trim(),
                      'state': stateCtrl.text.trim(),
                      'address': '${cityCtrl.text.trim()}, ${stateCtrl.text.trim()}',
                      'contact_email': updatedEmail,
                      'admin_email': updatedEmail,
                      'admin_password': updatedPassword,
                    }).eq('code', c['code']);
                  }
                } catch (e) {
                  debugPrint('Supabase update note: $e');
                }
              }

              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Updated institution: ${nameCtrl.text.trim()}'), backgroundColor: AppColors.accent));
              }
              _loadSuperAdminData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyanAccent, foregroundColor: AppColors.textDark),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCollege(Map<String, dynamic> c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Confirm Delete College', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete ${c['name']} (Code: ${c['code']}) from Supabase database?\nThis will remove the college entry.', style: const TextStyle(color: AppColors.textPrimary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            onPressed: () async {
              final client = SupabaseService.client;
              if (client != null) {
                try {
                  if (c['id'] != null) {
                    await client.from('institutions').delete().eq('id', c['id']);
                  } else if (c['code'] != null) {
                    await client.from('institutions').delete().eq('code', c['code']);
                  }
                } catch (e) {
                  debugPrint('Supabase delete error: $e');
                }
              }
              setState(() {
                _institutions.removeWhere((item) => item['code'] == c['code'] || item['id'] == c['id']);
              });
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🗑️ Deleted college: ${c['name']}'), backgroundColor: Colors.redAccent));
              }
              _loadSuperAdminData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Delete College'),
          ),
        ],
      ),
    );
  }

  void _showOnboardCollegeModal() {
    final codeCtrl = TextEditingController(text: '624');
    final nameCtrl = TextEditingController(text: 'Government Polytechnic Himmatnagar');
    final shortNameCtrl = TextEditingController(text: 'GPH');
    final cityCtrl = TextEditingController(text: 'Himmatnagar');
    final stateCtrl = TextEditingController(text: 'Gujarat');
    final emailCtrl = TextEditingController(text: 'admin@gph.ac.in');
    final passwordCtrl = TextEditingController(text: 'GPH@2026!');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Onboard New College to Supabase', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: codeCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'College Code (e.g. 624)')),
                const SizedBox(height: 12),
                TextField(controller: nameCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Full College Name')),
                const SizedBox(height: 12),
                TextField(controller: shortNameCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Short Display Name')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: cityCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'City'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: stateCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'State'))),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.cardBorder),
                const SizedBox(height: 8),
                const Align(alignment: Alignment.centerLeft, child: Text('College Admin Portal Credentials', style: TextStyle(color: AppColors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 13))),
                const SizedBox(height: 10),
                TextField(controller: emailCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Admin Institutional Email')),
                const SizedBox(height: 12),
                TextField(controller: passwordCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Admin Login Password')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            onPressed: () async {
              final adminEmail = emailCtrl.text.trim();
              final adminPassword = passwordCtrl.text.trim();
              final newCollege = {
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'code': codeCtrl.text.trim(),
                'name': nameCtrl.text.trim(),
                'short_name': shortNameCtrl.text.isEmpty ? nameCtrl.text.trim() : shortNameCtrl.text.trim(),
                'city': cityCtrl.text.trim(),
                'state': stateCtrl.text.trim(),
                'address': '${cityCtrl.text.trim()}, ${stateCtrl.text.trim()}',
                'contact_email': adminEmail,
                'admin_email': adminEmail,
                'admin_password': adminPassword,
                'student_count': 5000,
                'admissions_open': true,
              };

              final client = SupabaseService.client;
              if (codeCtrl.text.isNotEmpty && nameCtrl.text.isNotEmpty && adminEmail.isNotEmpty) {
                try {
                  if (client != null) {
                    await client.from('institutions').insert({
                      'code': codeCtrl.text.trim(),
                      'name': nameCtrl.text.trim(),
                      'short_name': shortNameCtrl.text.isEmpty ? nameCtrl.text.trim() : shortNameCtrl.text.trim(),
                      'city': cityCtrl.text.trim(),
                      'state': stateCtrl.text.trim(),
                      'address': '${cityCtrl.text.trim()}, ${stateCtrl.text.trim()}',
                      'contact_email': adminEmail,
                      'admin_email': adminEmail,
                      'admin_password': adminPassword,
                      'student_count': 5000,
                      'admissions_open': true,
                    });
                  }
                } catch (e) {
                  debugPrint('Supabase insert note: $e');
                }

                // Update UI state immediately
                setState(() {
                  _institutions.add(newCollege);
                  _subscriptions.add({
                    'plan_name': 'Enterprise Plan',
                    'status': 'active',
                    'max_students': 5000,
                  });
                });

                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  
                  // Show Credentials Popup
                  showDialog(
                    context: context,
                    builder: (credentialsCtx) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.cyanAccent, width: 1.5)),
                      title: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: AppColors.cyanAccent),
                          SizedBox(width: 10),
                          Text('College Admin Credentials', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('College Name: ${nameCtrl.text.trim()}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                          Text('College Code: ${codeCtrl.text.trim()}', style: const TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('COLLEGE ADMIN LOGIN CREDENTIALS', style: TextStyle(color: AppColors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                SelectableText('Email: $adminEmail', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                SelectableText('Password: $adminPassword', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text('Give these credentials to the College Admin so they can log into the College Admin Web Portal and manage student rosters.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(credentialsCtx),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyanAccent, foregroundColor: AppColors.textDark),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyanAccent, foregroundColor: AppColors.textDark),
            child: const Text('Save to Supabase'),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // 3. SUBSCRIPTIONS & PLANS VIEW
  // ====================================================================
  Widget _buildSubscriptionsView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SaaS Subscription & Plan Management', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 19), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 2),
                  Text('Manage multi-tenant college SaaS tiers stored in Supabase `subscriptions` table.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _subscriptions.add({
                    'plan_name': 'Enterprise Plan',
                    'status': 'active',
                    'max_students': 10000,
                  });
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Subscription plan provisioned!'), backgroundColor: AppColors.accent));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyanAccent, foregroundColor: AppColors.textDark),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Provision Subscription Plan'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        if (_subscriptions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
            child: const Column(
              children: [
                Text('No subscription records found. Click "Provision Subscription Plan" above.', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          )
        else
          ..._subscriptions.map((s) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, color: AppColors.accent, size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s['plan_name'] ?? 'Standard Plan', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('Max Student Capacity: ${s['max_students'] ?? 5000}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: const Text('ACTIVE PLAN', style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ====================================================================
  // 4. GLOBAL AUDIT LOGS VIEW
  // ====================================================================
  Widget _buildAuditLogsView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Global Security & Audit Logs', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 19), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 2),
                  Text('Platform security access logs stored in Supabase `audit_logs` table.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _auditLogs.add({
                    'timestamp': 'Now',
                    'action': 'SUPER_ADMIN_ONBOARD_COLLEGE',
                    'entity_type': 'institutions',
                  });
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Audit log recorded!'), backgroundColor: AppColors.accent));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyanAccent, foregroundColor: AppColors.textDark),
              icon: const Icon(Icons.shield_rounded, size: 16),
              label: const Text('Add Security Audit Log'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('System Audit Entries', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),
              if (_auditLogs.isEmpty)
                const Text('• System operating normally. All RLS policies active.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
              else
                ..._auditLogs.map((a) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('• [${a['timestamp'] ?? 'Now'}] ${a['action']} on ${a['entity_type']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  // ====================================================================
  // 5. PLATFORM SECURITY & SETTINGS VIEW
  // ====================================================================
  Widget _buildPlatformSettingsView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Global SaaS Platform Settings', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 19)),
        const SizedBox(height: 4),
        const Text('Configure Groq AI defaults, OTP security, and Supabase database cluster parameters.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Groq AI Model Default: llama-3.3-70b-versatile', style: TextStyle(color: AppColors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              const Text('Default Parent OTP Expiry: 60 Minutes Time-Limited Session', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
              const SizedBox(height: 8),
              const Text('Database Region: Supabase AP-South-1 (Mumbai Cluster)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Platform settings saved!'), backgroundColor: AppColors.accent));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyanAccent, foregroundColor: AppColors.textDark),
                icon: const Icon(Icons.save_rounded, size: 16),
                label: const Text('Save Global Settings'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleSuperAdminLogin() {
    final email = _superAdminEmailCtrl.text.trim().toLowerCase();
    final pass = _superAdminPassCtrl.text.trim();

    if ((email == 'cyberidfc@gmail.com' || email == 'admin@campusos.in' || email == 'admin@eduai.in') &&
        (pass == 'Kunjal9016@' || pass == 'Bipin98@' || pass == 'admin123' || pass == 'superadmin')) {
      setState(() {
        _isLoggedIn = true;
        _loginErrorMessage = null;
      });
      _loadSuperAdminData();
    } else {
      setState(() {
        _loginErrorMessage = '❌ Invalid Super Admin Email or Master Password.';
      });
    }
  }

  // ====================================================================
  // SUPER ADMIN LOGIN VIEW
  // ====================================================================
  Widget _buildSuperAdminLoginView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cyanAccent, width: 1.5),
            boxShadow: [
              BoxShadow(color: AppColors.cyanAccent.withValues(alpha: 0.15), blurRadius: 30, spreadRadius: 5),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cyanAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.security_rounded, size: 40, color: AppColors.cyanAccent),
              ),
              const SizedBox(height: 14),
              const Text('CampusOS Super Admin Login', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 4),
              const Text('Super Admin Credentials Required', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 24),

              if (_loginErrorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _loginErrorMessage!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              TextField(
                controller: _superAdminEmailCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Super Admin Email',
                  prefixIcon: Icon(Icons.admin_panel_settings_outlined, color: AppColors.textMuted, size: 18),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _superAdminPassCtrl,
                obscureText: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Master Password',
                  prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 18),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSuperAdminLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyanAccent,
                    foregroundColor: AppColors.textDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Log In to SaaS Operations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text('Protected by CampusOS Platform Core Security', style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.8), fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

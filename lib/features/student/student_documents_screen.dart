import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../chatbot/pdf_preview_screen.dart';

class StudentDocumentsScreen extends StatefulWidget {
  final String category;
  
  const StudentDocumentsScreen({super.key, required this.category});

  @override
  State<StudentDocumentsScreen> createState() => _StudentDocumentsScreenState();
}

class _StudentDocumentsScreenState extends State<StudentDocumentsScreen> {
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    try {
      final studentData = await Supabase.instance.client
          .from('students')
          .select('department, branch_name, semester, current_semester')
          .eq('profile_id', user.id)
          .maybeSingle();

      if (studentData != null) {
        final dept = studentData['department'] ?? studentData['branch_name'];
        final sem = studentData['semester'] ?? studentData['current_semester'];

        var query = Supabase.instance.client
            .from('documents')
            .select('*')
            .eq('category', widget.category);

        if (dept != null && dept.toString().isNotEmpty) {
          query = query.or('department.eq.$dept,department.eq.General,department.eq.All,department.is.null');
        }
        if (sem != null && sem.toString().isNotEmpty) {
          query = query.or('semester.eq.$sem,semester.eq.All,semester.is.null');
        }

        final docsResponse = await query.order('created_at', ascending: false);

        setState(() {
          _documents = List<Map<String, dynamic>>.from(docsResponse);
          _isLoading = false;
        });
      } else {
        // Fallback fetch all documents of this category
        final docsResponse = await Supabase.instance.client
            .from('documents')
            .select('*')
            .eq('category', widget.category)
            .order('created_at', ascending: false);

        setState(() {
          _documents = List<Map<String, dynamic>>.from(docsResponse);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String get _title {
    switch (widget.category) {
      case 'timetable': return '📅 Timetables';
      case 'lab_manual': return '📚 Lab Manuals';
      case 'assignment': return '📝 Assignments';
      case 'attendance_report': return '📊 Attendance Reports';
      case 'circular': return '📢 Circulars & Notices';
      case 'syllabus': return '📄 Syllabus';
      default: return '📁 Documents';
    }
  }

  Future<void> _downloadDoc(String url) async {
    String resolvedUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      resolvedUrl = Supabase.instance.client.storage.from('documents').getPublicUrl(url);
    }
    final uri = Uri.parse(resolvedUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDocs = _documents.where((doc) {
      final title = (doc['title'] ?? '').toString().toLowerCase();
      final subject = (doc['subject_name'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || subject.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          _title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // Spotlight Search Input Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder, width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
                decoration: const InputDecoration(
                  hintText: 'Search by title or subject...',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    onRefresh: _fetchDocuments,
                    color: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    child: filteredDocs.isEmpty
                        ? ListView(
                            physics: const BouncingScrollPhysics(),
                            children: [
                              const SizedBox(height: 120),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.folder_open_rounded, size: 54, color: AppColors.textMuted),
                                    const SizedBox(height: 14),
                                    Text(
                                      'No ${_title.replaceAll(RegExp(r'[^\w\s]'), '').trim()} uploaded yet.',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Your college admin will upload them soon.',
                                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: filteredDocs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final doc = filteredDocs[index];
                              final title = doc['title'] ?? 'Academic File';
                              final subject = doc['subject_name'] ?? '';
                              final fileUrl = doc['file_url'] ?? '';

                              return Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: AppColors.cardBorder, width: 1.1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                          ),
                                          child: const Icon(
                                            Icons.description_rounded,
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 14.5,
                                                  letterSpacing: -0.2,
                                                ),
                                              ),
                                              if (subject.toString().isNotEmpty) ...[
                                                const SizedBox(height: 3),
                                                Text(
                                                  subject,
                                                  style: const TextStyle(
                                                    color: AppColors.textSecondary,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    // Action Buttons: [ 👁️ Preview ] and [ 📥 Download ]
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              PdfPreviewScreen.show(
                                                context,
                                                title: title,
                                                category: widget.category,
                                                fileUrl: fileUrl,
                                                subject: subject,
                                              );
                                            },
                                            icon: const Icon(Icons.remove_red_eye_rounded, size: 15, color: AppColors.cyanAccent),
                                            label: const Text(
                                              'Preview',
                                              style: TextStyle(color: AppColors.cyanAccent, fontSize: 12.5, fontWeight: FontWeight.w800),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(color: AppColors.cyanAccent.withOpacity(0.5)),
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _downloadDoc(fileUrl),
                                            icon: const Icon(Icons.download_rounded, size: 15),
                                            label: const Text(
                                              'Download',
                                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: AppColors.background,
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(duration: 200.ms, delay: (index * 40).ms).slideY(begin: 0.05, end: 0);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

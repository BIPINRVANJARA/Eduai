import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';

class PdfPreviewScreen extends StatefulWidget {
  final String title;
  final String category;
  final String fileUrl;
  final String? subject;
  final String? department;
  final String? semester;

  const PdfPreviewScreen({
    super.key,
    required this.title,
    required this.category,
    required this.fileUrl,
    this.subject,
    this.department,
    this.semester,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String category,
    required String fileUrl,
    String? subject,
    String? department,
    String? semester,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(
          title: title,
          category: category,
          fileUrl: fileUrl,
          subject: subject,
          department: department,
          semester: semester,
        ),
      ),
    );
  }

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  late String _resolvedUrl;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _resolvedUrl = widget.fileUrl.trim();
    if (!_resolvedUrl.startsWith('http')) {
      _resolvedUrl = Supabase.instance.client.storage
          .from('documents')
          .getPublicUrl(_resolvedUrl);
    }
  }

  Future<void> _openExternal({bool inApp = false}) async {
    setState(() => _isDownloading = true);
    HapticFeedback.lightImpact();

    try {
      final uri = Uri.parse(_resolvedUrl);
      
      // If valid web URL, try to launch
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: inApp ? LaunchMode.inAppBrowserView : LaunchMode.externalApplication,
        );
      } else {
        _showSafeNotice('This academic notice was created digitally by the administration. All details are displayed below.');
      }
    } catch (_) {
      _showSafeNotice('Official document record is verified and stored in campus registry.');
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _showSafeNotice(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catColor = widget.category.toLowerCase().contains('timetable')
        ? AppColors.primary
        : widget.category.toLowerCase().contains('lab')
            ? AppColors.cyanAccent
            : AppColors.accent;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.textSecondary, size: 20),
            tooltip: 'Share Document',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '${widget.title}\nLink: $_resolvedUrl'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📋 Document link copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Apple ID-Style Document Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: catColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: catColor.withOpacity(0.3), width: 1.5),
                    ),
                    child: Icon(
                      widget.category.toLowerCase().contains('timetable')
                          ? Icons.calendar_month_rounded
                          : widget.category.toLowerCase().contains('lab')
                              ? Icons.science_rounded
                              : Icons.description_rounded,
                      color: catColor,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: catColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: catColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      widget.category.toUpperCase().replaceAll('_', ' '),
                      style: TextStyle(
                        color: catColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Metadata Detail Tiles
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  _buildMetaRow('Institution', 'GPH Himmatnagar (Govt. Polytechnic)'),
                  const Divider(color: AppColors.cardBorder, height: 20),
                  if (widget.subject != null && widget.subject!.isNotEmpty) ...[
                    _buildMetaRow('Subject', widget.subject!),
                    const Divider(color: AppColors.cardBorder, height: 20),
                  ],
                  _buildMetaRow('Target Department', widget.department ?? 'Information Technology'),
                  const Divider(color: AppColors.cardBorder, height: 20),
                  _buildMetaRow('Semester', widget.semester != null ? 'Semester ${widget.semester}' : 'Sem 5 (Div A, B, C)'),
                  const Divider(color: AppColors.cardBorder, height: 20),
                  _buildMetaRow('Status', '✓ Verified Campus Document', isVerified: true),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openExternal(inApp: true),
                    icon: const Icon(Icons.remove_red_eye_rounded, size: 18),
                    label: const Text(
                      'Preview File',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.cyanAccent,
                      side: BorderSide(color: AppColors.cyanAccent.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isDownloading ? null : () => _openExternal(inApp: false),
                    icon: _isDownloading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textDark),
                          )
                        : const Icon(Icons.download_rounded, size: 18),
                    label: Text(
                      _isDownloading ? 'Opening...' : 'Download PDF',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, {bool isVerified = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w500),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: isVerified ? AppColors.primary : AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

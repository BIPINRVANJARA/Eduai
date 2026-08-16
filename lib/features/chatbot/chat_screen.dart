import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/voice_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/chat_message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/college_provider.dart';
import 'pdf_preview_screen.dart';
import 'voice_assistant_sheet.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _suggestedChips = const [
    {'label': 'Timetable', 'emoji': '📅', 'prompt': 'Give me timetable of my branch and semester'},
    {'label': 'Lab Manuals', 'emoji': '📚', 'prompt': 'Give me lab manual for my subjects'},
    {'label': 'Assignments', 'emoji': '📝', 'prompt': 'Show me my pending assignments'},
    {'label': 'Attendance', 'emoji': '📊', 'prompt': 'What is my current attendance percentage and GTU eligibility?'},
    {'label': 'Campus Alerts', 'emoji': '📢', 'prompt': 'What are the latest campus notices and circulars?'},
    {'label': 'Syllabus', 'emoji': '📄', 'prompt': 'Show me the syllabus for my semester'},
    {'label': 'Exam Papers', 'emoji': '🏆', 'prompt': 'Show me previous year question papers'},
  ];

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _handleSend([String? textOverride]) {
    final text = textOverride ?? _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    ref.read(chatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _openVoiceAssistant() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const VoiceAssistantSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final college = ref.watch(selectedCollegeProvider);
    final authState = ref.watch(authProvider);
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.95),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            // Glowing AI Spark Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, Color(0xFF38BDF8)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.background,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (authState.isVerified) ...[
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          college.shortName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: authState.isVerified ? AppColors.accent : AppColors.primary,
                          boxShadow: [
                            BoxShadow(
                              color: (authState.isVerified ? AppColors.accent : AppColors.primary).withOpacity(0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          authState.isVerified
                              ? (authState.isParent
                                  ? '🛡️ Parent of ${authState.student?.studentName ?? 'Student'}'
                                  : 'Verified: ${authState.student?.studentName}')
                              : 'Eduai AI Copilot',
                          style: TextStyle(
                            color: authState.isVerified ? (authState.isParent ? AppColors.cyanAccent : AppColors.accent) : AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!authState.isVerified)
            IconButton(
              icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.textSecondary, size: 22),
              tooltip: 'Switch Institution',
              onPressed: () => context.push('/search-college'),
            ),
          IconButton(
            icon: const Icon(Icons.cleaning_services_rounded, color: AppColors.textSecondary, size: 18),
            tooltip: 'Clear Chat',
            onPressed: () => ref.read(chatProvider.notifier).clearChat(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Apple-style Quick Action Suggested Chips Carousel
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestedChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final item = _suggestedChips[idx];
                return GestureDetector(
                  onTap: () => _handleSend(item['prompt']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.cardBorder,
                        width: 1.1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item['emoji']!, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Text(
                          item['label']!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Stream
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: chatState.messages.length + (chatState.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatState.messages.length && chatState.isTyping) {
                  return _buildTypingIndicator();
                }
                final msg = chatState.messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Apple-style Floating Input Bar
          _buildInputBar(chatState),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel msg) {
    final isUser = msg.sender == ChatSender.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.only(right: 10, top: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E2838), Color(0xFF111722)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                  ),
                  child: const Center(
                    child: Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
                  ),
                ),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        gradient: isUser
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.primary, Color(0xFF8AC72E)],
                              )
                            : null,
                        color: isUser ? null : AppColors.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(5),
                          bottomRight: isUser ? const Radius.circular(5) : const Radius.circular(20),
                        ),
                        border: isUser ? null : Border.all(color: AppColors.cardBorder, width: 1.1),
                        boxShadow: [
                          BoxShadow(
                            color: isUser
                                ? AppColors.primary.withOpacity(0.2)
                                : Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: isUser
                          ? Text(
                              msg.text,
                              style: const TextStyle(
                                color: AppColors.background,
                                fontSize: 14,
                                height: 1.45,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.1,
                              ),
                            )
                          : MarkdownBody(
                              data: msg.text,
                              selectable: true,
                              styleSheet: MarkdownStyleSheet(
                                p: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  height: 1.55,
                                  letterSpacing: -0.1,
                                ),
                                strong: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                em: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                                h1: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.4,
                                ),
                                h2: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  height: 1.4,
                                ),
                                h3: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  height: 1.4,
                                ),
                                listBullet: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                tableHead: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                tableBody: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                ),
                                tableBorder: TableBorder.all(
                                  color: AppColors.cardBorder,
                                  width: 1,
                                ),
                                tableHeadAlign: TextAlign.left,
                                tableCellsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                code: const TextStyle(
                                  color: AppColors.primary,
                                  backgroundColor: AppColors.surfaceLight,
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                                codeblockDecoration: BoxDecoration(
                                  color: const Color(0xFF0D131F),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.cardBorder),
                                ),
                                horizontalRuleDecoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: AppColors.cardBorder.withOpacity(0.6),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                    if (!isUser) ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          VoiceService().speak(msg.text);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.volume_up_rounded, size: 14, color: AppColors.textSecondary.withOpacity(0.8)),
                            const SizedBox(width: 4),
                            Text(
                              'Listen',
                              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Interactive Academic Document Card
          if (msg.payload != null && msg.payload!['fileUrl'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 40),
              child: _buildDocumentCard(msg.payload!),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildDocumentCard(Map<String, dynamic> payload) {
    final title = payload['title'] ?? 'Academic Document';
    final category = payload['category'] ?? 'DOCUMENT';
    final subject = payload['subject'] ?? '';
    final dept = payload['department'] ?? '';
    final sem = payload['semester'] ?? '';
    final fileUrl = payload['fileUrl']?.toString() ?? '';

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            const Color(0xFF131C2E),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withOpacity(0.45), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Tag & Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(0.35)),
                ),
                child: Text(
                  category.toString().toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const Spacer(),
              if (sem.toString().isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Sem $sem',
                    style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Document Title
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),

          if (subject.toString().isNotEmpty || dept.toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              [subject, dept].where((s) => s.toString().isNotEmpty).join(' • '),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
              overflow: TextOverflow.ellipsis,
            ),
          ],

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
                      category: category,
                      fileUrl: fileUrl,
                      subject: subject.toString().isNotEmpty ? subject : null,
                      department: dept.toString().isNotEmpty ? dept : null,
                      semester: sem.toString().isNotEmpty ? sem : null,
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
                  onPressed: () {
                    PdfPreviewScreen.show(
                      context,
                      title: title,
                      category: category,
                      fileUrl: fileUrl,
                      subject: subject.toString().isNotEmpty ? subject : null,
                      department: dept.toString().isNotEmpty ? dept : null,
                      semester: sem.toString().isNotEmpty ? sem : null,
                    );
                  },
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
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Center(
              child: Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  'Eduai AI is thinking...',
                  style: TextStyle(color: AppColors.textSecondary.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(ChatState chatState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.cardBorder.withOpacity(0.4))),
      ),
      child: Row(
        children: [
          // 🎙️ Glowing Voice AI Mode Button
          GestureDetector(
            onTap: _openVoiceAssistant,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.mic_rounded, size: 22, color: AppColors.background),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.cardBorder, width: 1.2),
              ),
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                onSubmitted: (_) => _handleSend(),
                decoration: const InputDecoration(
                  hintText: 'Ask in Gujarati, Hindi, or English...',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _handleSend(),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, Color(0xFF8AC72E)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.arrow_upward_rounded, size: 22, color: AppColors.background),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

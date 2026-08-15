import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/supabase_service.dart';

class StudentChatScreen extends StatefulWidget {
  const StudentChatScreen({super.key});

  @override
  State<StudentChatScreen> createState() => _StudentChatScreenState();
}

class _Message {
  final String text;
  final bool isUser;
  final String? url;

  _Message({required this.text, required this.isUser, this.url});
}

class _StudentChatScreenState extends State<StudentChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_Message> _messages = [];
  bool _isTyping = false;
  Map<String, dynamic>? _studentData;

  @override
  void initState() {
    super.initState();
    _fetchStudentContext();
    _messages.add(_Message(
      text: "Hello! I'm your CampusOS AI assistant. Ask me about your timetables, lab manuals, assignments, or general college queries.",
      isUser: false,
    ));
  }

  Future<void> _fetchStudentContext() async {
    final user = AuthService.currentUser;
    if (user != null) {
      _studentData = await Supabase.instance.client
          .from('students')
          .select('branch_name, current_semester')
          .eq('profile_id', user.id)
          .maybeSingle();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    _textController.clear();
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    final lowerText = text.toLowerCase();
    String? responseText;
    String? responseUrl;

    try {
      // Rule-based routing
      if (lowerText.contains('timetable') || lowerText.contains('time table')) {
        if (_studentData != null) {
          final dept = _studentData!['department'] ?? _studentData!['branch_name'];
          final sem = _studentData!['semester'] ?? _studentData!['current_semester'];
          
          var query = Supabase.instance.client
              .from('documents')
              .select('*')
              .eq('category', 'timetable');
          if (dept != null && dept.toString().isNotEmpty) {
            query = query.eq('department', dept);
          }
          if (sem != null) {
            query = query.eq('semester', sem);
          }
          final doc = await query.maybeSingle();
              
          if (doc != null) {
            responseText = "Here is the latest timetable for your class:";
            final rawUrl = doc['file_url'] as String?;
            if (rawUrl != null && !rawUrl.startsWith('http')) {
              responseUrl = Supabase.instance.client.storage.from('documents').getPublicUrl(rawUrl);
            } else {
              responseUrl = rawUrl;
            }
          } else {
            responseText = "No timetable found for your department and semester. Please check with your admin.";
          }
        } else {
          responseText = "I couldn't identify your department. Please make sure your profile is complete.";
        }
      } else if (lowerText.contains('lab manual') || lowerText.contains('manual')) {
        if (_studentData != null) {
          final dept = _studentData!['department'] ?? _studentData!['branch_name'];
          final sem = _studentData!['semester'] ?? _studentData!['current_semester'];
          
          var query = Supabase.instance.client
              .from('documents')
              .select('*')
              .eq('category', 'lab_manual');
          if (dept != null && dept.toString().isNotEmpty) {
            query = query.eq('department', dept);
          }
          if (sem != null) {
            query = query.eq('semester', sem);
          }
          
          final docsResponse = await query;
          final docs = docsResponse as List;
          
          if (docs.isNotEmpty) {
            // Attempt subject matching
            Map<String, dynamic>? bestMatch;
            for (var d in docs) {
              final sub = (d['subject_name'] ?? '').toString().toLowerCase();
              final title = (d['title'] ?? '').toString().toLowerCase();
              if (sub.isNotEmpty && lowerText.contains(sub) || title.isNotEmpty && lowerText.contains(title)) {
                bestMatch = d;
                break;
              }
            }
            // If no exact match, return the first one
            bestMatch ??= docs.first as Map<String, dynamic>;
            
            responseText = "Here is the lab manual for ${bestMatch['subject_name'] ?? bestMatch['title']}:";
            final rawUrl = bestMatch['file_url'] as String?;
            if (rawUrl != null && !rawUrl.startsWith('http')) {
              responseUrl = Supabase.instance.client.storage.from('documents').getPublicUrl(rawUrl);
            } else {
              responseUrl = rawUrl;
            }
          } else {
            responseText = "No lab manuals found for your class.";
          }
        }
      }

      // Fallback to Groq AI
      if (responseText == null) {
        final aiResponse = await SupabaseService.queryGroqDirect(
          userText: text,
          collegeName: "CampusOS College",
          isVerified: _studentData != null,
        );
        responseText = aiResponse ?? "Sorry, I couldn't process your request right now.";
      }
    } catch (e) {
      responseText = "An error occurred while processing your request.";
    }

    setState(() {
      _isTyping = false;
      _messages.add(_Message(text: responseText!, isUser: false, url: responseUrl));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildBubble(_messages[index]);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildBubble(_Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(message.isUser ? 20 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 20),
          ),
          border: Border.all(
            color: message.isUser ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? AppColors.textDark : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: message.isUser ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (message.url != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(message.url!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Download Document'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  foregroundColor: AppColors.cyanAccent,
                  elevation: 0,
                  side: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 10),
            Text('Thinking...', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: (_) => _handleSend(),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Ask about timetable, manuals...',
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _handleSend,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textDark,
              ),
              icon: const Icon(Icons.send_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

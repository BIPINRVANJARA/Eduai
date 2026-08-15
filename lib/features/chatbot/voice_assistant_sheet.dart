import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/voice_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/college_model.dart';
import '../../models/student_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/college_provider.dart';
import 'pdf_preview_screen.dart';

class VoiceAssistantSheet extends ConsumerStatefulWidget {
  const VoiceAssistantSheet({super.key});

  @override
  ConsumerState<VoiceAssistantSheet> createState() => _VoiceAssistantSheetState();
}

class _VoiceAssistantSheetState extends ConsumerState<VoiceAssistantSheet>
    with SingleTickerProviderStateMixin {
  final VoiceService _voiceService = VoiceService();
  late AnimationController _pulseController;

  VoiceState _voiceState = VoiceState.idle;
  String _liveTranscript = '';
  String _aiResponseText = '';
  Map<String, dynamic>? _attachedDocPayload;
  double _soundLevel = 0.0;
  bool _isProcessingQuery = false;

  final List<String> _quickPrompts = [
    'Give me Blockchain Assignment',
    'What are my CLOUD marks?',
    'Show Sem 5 Timetable',
    'What is my GTU attendance percentage?',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _initVoiceListeners();
    _startVoiceSession();
  }

  void _initVoiceListeners() {
    _voiceService.stateStream.listen((state) {
      if (mounted) {
        setState(() => _voiceState = state);
      }
    });

    _voiceService.soundLevelStream.listen((level) {
      if (mounted) {
        setState(() => _soundLevel = (level / 10).clamp(0.0, 1.0));
      }
    });

    _voiceService.wordsStream.listen((words) {
      if (mounted) {
        setState(() => _liveTranscript = words);
      }
    });
  }

  Future<void> _startVoiceSession() async {
    final college = ref.read(selectedCollegeProvider);
    final authState = ref.read(authProvider);

    await _voiceService.startListening(
      onResult: (words, isFinal) {
        setState(() => _liveTranscript = words);
        if (isFinal && words.trim().isNotEmpty && !_isProcessingQuery) {
          _handleQuery(words.trim(), college, authState.student);
        }
      },
    );
  }

  Future<void> _handleQuery(
    String query,
    CollegeModel college,
    StudentModel? student,
  ) async {
    setState(() {
      _isProcessingQuery = true;
      _liveTranscript = query;
      _aiResponseText = 'Analyzing campus records...';
      _attachedDocPayload = null;
    });

    HapticFeedback.mediumImpact();

    try {
      // 1. Send query to Chat Provider
      final chatNotifier = ref.read(chatProvider.notifier);
      await chatNotifier.sendMessage(query);

      // 2. Read the latest message from ChatState
      final chatState = ref.read(chatProvider);
      final lastMsg = chatState.messages.isNotEmpty ? chatState.messages.last : null;

      final responseText = lastMsg?.text ??
          'I have found the academic information you requested.';

      if (mounted) {
        setState(() {
          _isProcessingQuery = false;
          _aiResponseText = responseText;
          _attachedDocPayload = lastMsg?.payload;
        });

        // 3. Speak the AI response back to user
        await _voiceService.speak(responseText);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessingQuery = false;
          _aiResponseText = 'Sorry, could not fetch records at this moment.';
          _attachedDocPayload = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _voiceService.stopAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final college = ref.watch(selectedCollegeProvider);
    final authState = ref.watch(authProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 50,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Ambient Gradient Blurs
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyanAccent.withOpacity(0.08),
              ),
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                children: [
                  // Top Drag Handle
                  Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.asset(
                                'assets/images/app_logo.png',
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, st) => const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                college.shortName.isNotEmpty ? college.shortName : 'Eduai Voice AI',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                authState.isParent
                                    ? 'Guardian Voice (English • ગુજરાતી • हिंदी)'
                                    : 'Student Voice (English • ગુજરાતી • हिंदी)',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          side: const BorderSide(color: AppColors.cardBorder),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 🌟 GLOWING APPLE INTELLIGENCE ORB & SOUNDWAVE
                  Center(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = _voiceState == VoiceState.listening
                            ? 1.0 + (_soundLevel * 0.35)
                            : (_voiceState == VoiceState.speaking
                                ? 1.0 + (math.sin(_pulseController.value * math.pi * 2) * 0.10)
                                : 1.0 + (_pulseController.value * 0.05));

                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _voiceState == VoiceState.listening
                                      ? AppColors.primary
                                      : (_voiceState == VoiceState.speaking
                                          ? AppColors.cyanAccent
                                          : const Color(0xFF818CF8)),
                                  _voiceState == VoiceState.listening
                                      ? AppColors.cyanAccent
                                      : const Color(0xFFC084FC),
                                  AppColors.surface,
                                ],
                                stops: const [0.25, 0.70, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_voiceState == VoiceState.listening
                                          ? AppColors.primary
                                          : AppColors.cyanAccent)
                                      .withOpacity(0.45),
                                  blurRadius: 45,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                _voiceState == VoiceState.listening
                                    ? Icons.mic_rounded
                                    : (_voiceState == VoiceState.speaking
                                        ? Icons.volume_up_rounded
                                        : Icons.graphic_eq_rounded),
                                color: AppColors.background,
                                size: 44,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Voice State Indicator Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _voiceState == VoiceState.listening
                            ? AppColors.primary.withOpacity(0.6)
                            : AppColors.cardBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _voiceState == VoiceState.listening
                                ? AppColors.primary
                                : (_voiceState == VoiceState.speaking
                                    ? AppColors.cyanAccent
                                    : AppColors.textSecondary),
                          ),
                        ).animate(onPlay: (c) => c.repeat()).scale(
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1.3, 1.3),
                              duration: 800.ms,
                            ),
                        const SizedBox(width: 8),
                        Text(
                          _voiceState == VoiceState.listening
                              ? 'Listening (Speak now)...'
                              : (_voiceState == VoiceState.speaking
                                  ? 'Eduai Voice Responding...'
                                  : (_isProcessingQuery
                                      ? 'Searching Academic Records...'
                                      : 'Tap Mic to Ask')),
                          style: TextStyle(
                            color: _voiceState == VoiceState.listening
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Quick Suggestion Prompts Scroll
                  if (_liveTranscript.isEmpty && _aiResponseText.isEmpty) ...[
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _quickPrompts.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final p = _quickPrompts[idx];
                          return GestureDetector(
                            onTap: () {
                              _handleQuery(p, college, authState.student);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Text(
                                p,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Live Real-Time Transcript & Verified Document Card
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          if (_liveTranscript.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.primary),
                                const SizedBox(width: 6),
                                const Text(
                                  'You said:',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '"$_liveTranscript"',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: AppColors.cardBorder, height: 1),
                            const SizedBox(height: 12),
                          ],

                          if (_aiResponseText.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.cyanAccent),
                                const SizedBox(width: 6),
                                const Text(
                                  'Eduai AI Response:',
                                  style: TextStyle(
                                    color: AppColors.cyanAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _aiResponseText,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),

                            // 📄 VERIFIED DOCUMENT CARD WITH PREVIEW & DOWNLOAD
                            if (_attachedDocPayload != null && _attachedDocPayload!['fileUrl'] != null) ...[
                              const SizedBox(height: 14),
                              _buildAttachedDocumentCard(context, _attachedDocPayload!),
                            ],
                          ] else if (_liveTranscript.isEmpty) ...[
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Text(
                                  'Ask anything about your syllabus, attendance, assignments, lab manuals, or mid-sem marks!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom Controls Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Stop / Mute Voice Playback Button
                      IconButton.filledTonal(
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          if (_voiceState == VoiceState.speaking) {
                            await _voiceService.stopSpeaking();
                          } else if (_voiceState == VoiceState.listening) {
                            await _voiceService.stopListening();
                          }
                        },
                        icon: const Icon(Icons.stop_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.danger,
                          side: BorderSide(color: AppColors.danger.withOpacity(0.3)),
                          padding: const EdgeInsets.all(16),
                        ),
                      ),

                      // Large Center Mic Pulse Button
                      GestureDetector(
                        onTap: () async {
                          HapticFeedback.mediumImpact();
                          if (_voiceState == VoiceState.listening) {
                            await _voiceService.stopListening();
                          } else {
                            await _startVoiceSession();
                          }
                        },
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.cyanAccent],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 22,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _voiceState == VoiceState.listening
                                  ? Icons.pause_rounded
                                  : Icons.mic_rounded,
                              color: AppColors.background,
                              size: 32,
                            ),
                          ),
                        ),
                      ),

                      // Keyboard Switch Button
                      IconButton.filledTonal(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.keyboard_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.cardBorder),
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachedDocumentCard(BuildContext context, Map<String, dynamic> payload) {
    final title = payload['title'] ?? 'Academic Document';
    final category = payload['category'] ?? 'DOCUMENT';
    final subject = payload['subject'] ?? '';
    final dept = payload['department'] ?? '';
    final sem = payload['semester'] ?? '';
    final fileUrl = payload['fileUrl']?.toString() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category.toString().toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              if (sem.toString().isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Sem $sem',
                    style: const TextStyle(color: AppColors.cyanAccent, fontSize: 10.5, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subject.toString().isNotEmpty || dept.toString().isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              [subject, dept].where((s) => s.toString().isNotEmpty).join(' • '),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
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
                      subject: subject,
                      department: dept,
                      semester: sem.toString(),
                    );
                  },
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 14),
                  label: const Text('Preview', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cyanAccent,
                    side: BorderSide(color: AppColors.cyanAccent.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
                      subject: subject,
                      department: dept,
                      semester: sem.toString(),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 14),
                  label: const Text('Download', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
}

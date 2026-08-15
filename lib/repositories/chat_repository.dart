import '../core/services/supabase_service.dart';
import '../models/chat_message_model.dart';
import '../models/college_model.dart';
import '../models/student_model.dart';

class ChatRepository {
  Future<ChatMessageModel> processUserMessageAsync({
    required String userText,
    required CollegeModel college,
    required bool isVerified,
    StudentModel? student,
    List<ChatMessageModel>? conversationHistory,
  }) async {
    final lower = userText.toLowerCase();
    final bool isGujarati = RegExp(r'[\u0A80-\u0AFF]').hasMatch(userText);

    final bool isStudentDataQuery = lower.contains('attendance') ||
        lower.contains('attendence') ||
        lower.contains('percentage') ||
        lower.contains('eligibility') ||
        lower.contains('eligible') ||
        lower.contains('gtu') ||
        lower.contains('હાજરી') ||
        lower.contains('mark') ||
        lower.contains('marks') ||
        lower.contains('માર્ક્સ') ||
        lower.contains('માર્ક') ||
        lower.contains('result') ||
        lower.contains('પરિણામ') ||
        lower.contains('score') ||
        lower.contains('internal') ||
        lower.contains('performance') ||
        lower.contains('progress') ||
        lower.contains('grade');

    // 1. Intelligent Multi-Tag & Multilingual Document Search (Only for document requests)
    final String currentInstId = (student?.collegeId.isNotEmpty == true
            ? student!.collegeId
            : college.id)
        .trim();

    if (!isStudentDataQuery) {
      try {
        if (SupabaseService.client != null) {
          var docQuery = SupabaseService.client!.from('documents').select('*');
          if (currentInstId.isNotEmpty) {
            docQuery = docQuery.eq('institution_id', currentInstId);
          }

          final docsRes = await docQuery
              .order('created_at', ascending: false)
              .limit(30);

          final docsList = (docsRes as List?) ?? [];
          if (docsList.isNotEmpty) {
            Map<String, dynamic>? bestDoc;
            int highestScore = 0;

            for (final rawDoc in docsList) {
              final doc = Map<String, dynamic>.from(rawDoc);
              int score = 0;

              final title = (doc['title'] ?? '').toString().toLowerCase();
              final category = (doc['category'] ?? '').toString().toLowerCase();
              final dept = (doc['department'] ?? '').toString().toLowerCase();
              final sem = (doc['semester'] ?? '').toString();
              final subject = (doc['subject_name'] ?? '').toString().toLowerCase();
              final tags = (doc['tags'] as List?)?.map((t) => t.toString().toLowerCase()).toList() ?? [];

              // Tag & Multilingual Match
              for (final tag in tags) {
                if (tag.isNotEmpty && (lower.contains(tag) || tag.contains(lower))) {
                  score += 20;
                }
              }

              // Category & Intent Match (English + Gujarati + Hindi)
              final isTTIntent = lower.contains('timetable') ||
                  lower.contains('time table') ||
                  lower.contains('schedule') ||
                  lower.contains('tt') ||
                  lower.contains('સમયપત્રક') ||
                  lower.contains('સમય પત્રક') ||
                  lower.contains('ટાઈમટેબલ') ||
                  lower.contains('ટાઈમ ટેબલ') ||
                  lower.contains('समय सारणी');

              final isLabIntent = lower.contains('lab') ||
                  lower.contains('manual') ||
                  lower.contains('practical') ||
                  lower.contains('લેબ') ||
                  lower.contains('મેન્યુઅલ') ||
                  lower.contains('પ્રાયોગિક') ||
                  lower.contains('પુસ્તિકા') ||
                  lower.contains('पुस्तिका');

              final isAssignIntent = lower.contains('assignment') ||
                  lower.contains('homework') ||
                  lower.contains('problem set') ||
                  lower.contains('એસાઇનમેન્ટ') ||
                  lower.contains('એસાઈનમેન્ટ') ||
                  lower.contains('સ્વાધ્યાય') ||
                  lower.contains('હોમવર્ક') ||
                  lower.contains('fbc');

              final isCircularIntent = lower.contains('circular') ||
                  lower.contains('notice') ||
                  lower.contains('પરિપત્ર') ||
                  lower.contains('નોટિસ') ||
                  lower.contains('સૂચના');

              final isSyllabusIntent = lower.contains('syllabus') ||
                  lower.contains('curriculum') ||
                  lower.contains('અભ્યાસક્રમ');

              if (category == 'timetable' && isTTIntent) {
                score += 25;
              } else if (category == 'lab_manual' && isLabIntent) {
                score += 25;
              } else if (category == 'assignment' && isAssignIntent) {
                score += 25;
              } else if (category == 'circular' && isCircularIntent) {
                score += 25;
              } else if (category == 'syllabus' && isSyllabusIntent) {
                score += 25;
              }

              // Title & Subject Match
              if (title.isNotEmpty && (lower.contains(title) || title.contains(lower))) score += 15;
              if (subject.isNotEmpty && (lower.contains(subject) || subject.contains(lower))) score += 15;

              // Department Match (boost only if intent or title already matched)
              if (score > 0 && dept.isNotEmpty) {
                if ((lower.contains('it') || lower.contains('information')) &&
                    (dept.contains('information technology') || dept.contains('it'))) {
                  score += 5;
                } else if (student != null && student.branch.toLowerCase().contains(dept)) {
                  score += 2;
                }
              }

              // Semester Match
              if (score > 0 && sem.isNotEmpty) {
                final semTokens = sem.replaceAll(RegExp(r'[^0-9]'), ' ').split(' ').where((s) => s.trim().isNotEmpty);
                for (final s in semTokens) {
                  if (lower.contains('sem $s') || lower.contains('semester $s') || lower.contains('સેમ $s')) {
                    score += 5;
                  }
                }
              }

              if (score > highestScore) {
                highestScore = score;
                bestDoc = doc;
              }
            }

            // If confident document match found (score >= 20)
            if (bestDoc != null && highestScore >= 20) {
              final cat = (bestDoc['category'] ?? 'Document').toString();
              final title = bestDoc['title'] ?? 'Academic Document';
              final dept = bestDoc['department'] ?? '';
              final sem = bestDoc['semester'] ?? '';
              final subject = bestDoc['subject_name'] ?? '';

              String categoryDisplay = cat.replaceAll('_', ' ').toUpperCase();
              String label;

              if (isGujarati) {
                if (cat == 'timetable') {
                  label = 'અહીં **$title** ($dept સેમેસ્ટર $sem) માટેનું ઓફિશિયલ સમયપત્રક (Timetable) છે:';
                } else if (cat == 'lab_manual') {
                  label = 'અહીં **${subject.isNotEmpty ? subject : title}** ($dept સેમેસ્ટર $sem) માટેની લેબ મેન્યુઅલ છે:';
                } else if (cat == 'assignment') {
                  label = 'અહીં **${subject.isNotEmpty ? subject : title}** ($dept સેમેસ્ટર $sem) માટેનું એસાઇનમેન્ટ છે:';
                } else if (cat == 'circular') {
                  label = 'અહીં **$title** નો ઓફિશિયલ પરિપત્ર / નોટિસ છે:';
                } else {
                  label = 'અહીં તમે માંગેલ **$title** ($categoryDisplay) દસ્તાવેજ છે:';
                }
              } else {
                label = 'Here is the **$categoryDisplay** you requested:';
                if (cat == 'timetable') {
                  label = 'Here is the latest **Timetable** for **$title** ($dept Sem $sem):';
                } else if (cat == 'lab_manual') {
                  label = 'Here is the **Lab Manual** for **${subject.isNotEmpty ? subject : title}** ($dept Sem $sem):';
                } else if (cat == 'assignment') {
                  label = 'Here is the latest **Assignment** for **${subject.isNotEmpty ? subject : title}** ($dept Sem $sem):';
                } else if (cat == 'circular') {
                  label = 'Here is the **Circular / Notice** regarding **$title**:';
                } else if (cat == 'syllabus') {
                  label = 'Here is the **Syllabus / Curriculum** for **${subject.isNotEmpty ? subject : title}** ($dept Sem $sem):';
                } else if (cat == 'notes' || cat == 'study_material') {
                  label = 'Here are the **Lecture Notes / Study Material** for **${subject.isNotEmpty ? subject : title}**:';
                } else if (cat == 'pyq' || cat == 'exam_paper') {
                  label = 'Here is the **Previous Exam Paper / PYQ** for **${subject.isNotEmpty ? subject : title}**:';
                } else if (cat == 'fee_structure') {
                  label = 'Here is the **Fee Structure & Guidelines** for **$title**:';
                } else if (cat == 'placement' || cat == 'internship') {
                  label = 'Here is the **Placement / Internship Guide** for **$title**:';
                } else if (cat == 'project') {
                  label = 'Here is the **Project Guideline & Template** for **$title**:';
                } else {
                  label = 'Here is the **$title** ($categoryDisplay) you requested:';
                }
              }

              return ChatMessageModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                sender: ChatSender.ai,
                text: label,
                timestamp: DateTime.now(),
                dataType: cat == 'timetable' ? ChatDataType.timetable : ChatDataType.none,
                payload: {
                  'fileUrl': bestDoc['file_url'],
                  'title': title,
                  'category': categoryDisplay,
                  'subject': subject,
                  'department': dept,
                  'semester': sem,
                },
              );
            }
          }
        }
      } catch (e) {
        // Fallback to Groq Direct AI
      }
    }

    // 2. Direct Groq AI API Call with Multi-Turn History & Anti-Hallucination
    final groqDirectReply = await SupabaseService.queryGroqDirect(
      userText: userText,
      collegeName: college.name,
      isVerified: isVerified,
      student: student,
      conversationHistory: conversationHistory,
      institutionId: currentInstId,
    );

    if (groqDirectReply != null && groqDirectReply.isNotEmpty) {
      String responseText = groqDirectReply;
      Map<String, dynamic>? attachedPayload;

      // Extract [ATTACH_DOC:<doc_id>] if present
      final attachDocRegex = RegExp(r'\[ATTACH_DOC:(.*?)\]');
      final match = attachDocRegex.firstMatch(responseText);
      if (match != null) {
        final docId = match.group(1)?.trim();
        responseText = responseText.replaceAll(attachDocRegex, '').trim();

        if (docId != null && docId.isNotEmpty && SupabaseService.client != null) {
          try {
            final docFetch = await SupabaseService.client!
                .from('documents')
                .select('*')
                .eq('id', docId)
                .maybeSingle();

            if (docFetch != null) {
              final d = Map<String, dynamic>.from(docFetch);
              attachedPayload = {
                'fileUrl': d['file_url'],
                'title': d['title'],
                'category': (d['category'] ?? 'DOCUMENT').toString().replaceAll('_', ' ').toUpperCase(),
                'subject': d['subject_name'] ?? '',
                'department': d['department'] ?? '',
                'semester': d['semester'] ?? '',
              };
            }
          } catch (_) {}
        }
      }

      return ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: ChatSender.ai,
        text: responseText,
        timestamp: DateTime.now(),
        requiresVerification: false,
        dataType: attachedPayload != null ? ChatDataType.timetable : ChatDataType.none,
        payload: attachedPayload,
      );
    }

    // 3. Fallback processor
    return processUserMessage(
      userText: userText,
      college: college,
      isVerified: isVerified,
      student: student,
    );
  }

  ChatMessageModel processUserMessage({
    required String userText,
    required CollegeModel college,
    required bool isVerified,
    StudentModel? student,
  }) {
    final text = userText.toLowerCase();

    // Check for private / student-specific intent
    final isPrivateIntent = text.contains('attendance') ||
        text.contains('mark') ||
        text.contains('result') ||
        text.contains('grade') ||
        text.contains('fee') ||
        text.contains('due') ||
        text.contains('timetable') ||
        text.contains('schedule') ||
        text.contains('son') ||
        text.contains('daughter') ||
        text.contains('child') ||
        text.contains('class') ||
        text.contains('assignment');

    if (isPrivateIntent && !isVerified) {
      return ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: ChatSender.ai,
        text:
            'To protect student privacy and comply with campus data security standards, please verify your parent identity with student enrollment details.',
        timestamp: DateTime.now(),
        requiresVerification: true,
        dataType: ChatDataType.none,
      );
    }

    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: ChatSender.ai,
      text:
          'I am here to assist you with ${college.shortName}. You can ask me for timetables, lab manuals, assignments, syllabus, or attendance updates.',
      timestamp: DateTime.now(),
      dataType: ChatDataType.none,
    );
  }
}

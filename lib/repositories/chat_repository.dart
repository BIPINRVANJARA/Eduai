import '../core/services/academic_solver_service.dart';
import '../core/services/supabase_service.dart';
import '../models/chat_message_model.dart';
import '../models/college_model.dart';
import '../models/student_model.dart';

class ChatRepository {
  static final Set<String> _conversationalWords = {
    'give', 'me', 'please', 'show', 'tell', 'send', 'share', 'can', 'you',
    'i', 'need', 'want', 'where', 'is', 'the', 'what', 'a', 'an', 'of',
    'for', 'about', 'with', 'pdf', 'file', 'document', 'download', 'view', 'get',
    'krupya', 'aapo', 'moklo', 'batavo', 'de', 'do', 'aap'
  };

  static String _cleanSearchQuery(String text) {
    final tokens = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s\u0A80-\u0AFF\u0900-\u097F]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty && !_conversationalWords.contains(t))
        .toList();
    return tokens.isNotEmpty ? tokens.join(' ') : text;
  }

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

    final bool isQuestionAnsweringRequest = lower.contains('que') ||
        lower.contains('question') ||
        lower.contains('ans') ||
        lower.contains('answer') ||
        lower.contains('solve') ||
        lower.contains('solution') ||
        lower.contains('explain') ||
        lower.contains('step') ||
        lower.contains('what is') ||
        lower.contains('how to') ||
        lower.contains('define') ||
        lower.contains('describe') ||
        lower.contains('summary') ||
        lower.contains('પ્રશ્ન') ||
        lower.contains('જવાબ') ||
        lower.contains('ઉકેલ') ||
        lower.contains('સમજાવો') ||
        lower.contains('વિસ્તાર') ||
        lower.contains('उत्तर') ||
        lower.contains('हल') ||
        lower.contains('समझाएं');

    // 1. Direct Student Attendance, Marks & GTU Eligibility Resolver
    if (isStudentDataQuery) {
      try {
        if (SupabaseService.client != null) {
          final currentUser = SupabaseService.client!.auth.currentUser;
          Map<String, dynamic>? studentRec;
          
          if (currentUser != null) {
            studentRec = await SupabaseService.client!
                .from('students')
                .select('*')
                .or('profile_id.eq.${currentUser.id},email.eq.${currentUser.email}')
                .maybeSingle();
          }

          if (studentRec == null && student != null && student.enrollmentNo.isNotEmpty) {
            studentRec = await SupabaseService.client!
                .from('students')
                .select('*')
                .eq('enrollment_no', student.enrollmentNo)
                .maybeSingle();
          }

          if (studentRec != null) {
            final name = studentRec['full_name'] ?? student?.studentName ?? 'Student';
            final enr = studentRec['enrollment_no'] ?? student?.enrollmentNo ?? '';
            final attVal = studentRec['overall_attendance'] ?? student?.overallAttendance ?? 85.0;
            final double att = (attVal is num ? attVal : double.tryParse(attVal.toString()) ?? 85.0).toDouble();
            final marks = studentRec['marks_data'] as Map<String, dynamic>? ?? {};
            final bool isEligible = att >= 75.0;
            final dept = studentRec['department'] ?? 'Information Technology';
            final sem = studentRec['semester'] ?? '5';

            final buffer = StringBuffer();
            if (isGujarati) {
              buffer.writeln('📊 **વિદ્યાર્થી હાજરી અને પ્રગતિ રિપોર્ટ**\n');
              buffer.writeln('👤 **વિદ્યાર્થી:** $name');
              buffer.writeln('🆔 **એનરોલમેન્ટ:** `$enr`');
              buffer.writeln('🏫 **વિભાગ:** $dept (સેમેસ્ટર $sem)\n');
              buffer.writeln('📈 **કુલ હાજરી (Overall Attendance):** **${att.toStringAsFixed(1)}%**');
              if (isEligible) {
                buffer.writeln('✅ **GTU પરીક્ષા પાત્રતા:** **પાત્ર (Eligible)** (75% થી વધુ હાજરી છે)\n');
              } else {
                buffer.writeln('⚠️ **GTU પરીક્ષા પાત્રતા:** **અપાત્ર / ડિફોલ્ટર (Not Eligible)** (નિયમ મુજબ 75% હાજરી જરૂરી છે)\n');
              }

              if (marks.isNotEmpty) {
                buffer.writeln('📚 **વિષય મુજબ વિગતો:**');
                marks.forEach((sub, val) {
                  final d = val as Map<String, dynamic>? ?? {};
                  buffer.writeln('• **$sub**: મિડ-સેમ: ${d['mid_sem'] ?? '—'}/30, પ્રેક્ટિકલ: ${d['practical'] ?? '—'}/30, હાજરી: ${d['attendance'] ?? '—'}%');
                });
              }
            } else {
              buffer.writeln('📊 **Student Academic & Attendance Status**\n');
              buffer.writeln('👤 **Student:** $name');
              buffer.writeln('🆔 **Enrollment No:** `$enr`');
              buffer.writeln('🏫 **Department:** $dept (Semester $sem)\n');
              buffer.writeln('📈 **Overall Attendance:** **${att.toStringAsFixed(1)}%**');
              if (isEligible) {
                buffer.writeln('✅ **GTU Exam Eligibility:** **ELIGIBLE** (Meets the ≥75% mandatory university requirement)\n');
              } else {
                buffer.writeln('⚠️ **GTU Exam Eligibility:** **DEFAULTER / AT RISK** (Below the 75% GTU threshold. Please attend upcoming lectures to avoid detention.)\n');
              }

              if (marks.isNotEmpty) {
                buffer.writeln('📚 **Subject-wise Performance Breakdown:**');
                marks.forEach((sub, val) {
                  final d = val as Map<String, dynamic>? ?? {};
                  buffer.writeln('• **$sub**: Mid-Sem: `${d['mid_sem'] ?? '—'}/30`, Practical: `${d['practical'] ?? '—'}/30`, Subject Attendance: `${d['attendance'] ?? '—'}%`');
                });
              }
            }

            return ChatMessageModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              sender: ChatSender.ai,
              text: buffer.toString().trim(),
              timestamp: DateTime.now(),
              dataType: ChatDataType.none,
            );
          }
        }
      } catch (e) {
        // Fallback to Groq
      }
    }

    // 2. RAG Document & Content Search
    final String currentInstId = (student?.collegeId.isNotEmpty == true
            ? student!.collegeId
            : college.id)
        .trim();

    // Clean conversational stopwords from query for full-text search
    final cleanedQuery = _cleanSearchQuery(userText);

    // Detect if user wants to VIEW / DOWNLOAD an official document
    final bool isDocFetchIntent = lower.contains('timetable') ||
        lower.contains('time table') ||
        lower.contains('schedule') ||
        lower.contains('tt') ||
        lower.contains('સમયપત્રક') ||
        lower.contains('ટાઈમટેબલ') ||
        lower.contains('lab manual') ||
        lower.contains('labmanual') ||
        lower.contains('practical') ||
        lower.contains('લેબ') ||
        lower.contains('મેન્યુઅલ') ||
        lower.contains('assignment') ||
        lower.contains('એસાઇનમેન્ટ') ||
        lower.contains('syllabus') ||
        lower.contains('curriculum') ||
        lower.contains('અભ્યાસક્રમ') ||
        lower.contains('circular') ||
        lower.contains('notice') ||
        lower.contains('notes') ||
        lower.contains('pdf') ||
        lower.contains('file') ||
        lower.contains('download') ||
        lower.contains('દસ્તાવેજ');

    // A. Priority RAG Document Attachment (When user asks for a document / timetable / assignment)
    if (!isStudentDataQuery && isDocFetchIntent && !isQuestionAnsweringRequest && SupabaseService.client != null) {
      try {
        final chunksRes = await SupabaseService.client!.rpc('search_document_chunks', params: {
          'query_text': cleanedQuery.isNotEmpty ? cleanedQuery : userText,
          'match_count': 3,
          'filter_institution_id': currentInstId.isNotEmpty ? currentInstId : null,
          'filter_department': null, // Search across all campus documents for accurate matching
        });

        if (chunksRes != null && (chunksRes as List).isNotEmpty) {
          final topChunk = chunksRes.first;
          final docId = topChunk['document_id'] as String?;

          if (docId != null && docId.isNotEmpty) {
            final docFetch = await SupabaseService.client!
                .from('documents')
                .select('*')
                .eq('id', docId)
                .maybeSingle();

            if (docFetch != null) {
              final cat = (docFetch['category'] ?? 'document').toString();
              final title = docFetch['title'] ?? 'Academic Document';
              final dept = docFetch['department'] ?? '';
              final sem = docFetch['semester'] ?? '';
              final subject = docFetch['subject_name'] ?? '';

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
                  'fileUrl': docFetch['file_url'],
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
        // Fallback to Groq AI
      }
    }

    // B. RAG Full-Text Search for Question Answering
    if (isQuestionAnsweringRequest && SupabaseService.client != null) {
      try {
        final chunksRes = await SupabaseService.client!.rpc('search_document_chunks', params: {
          'query_text': cleanedQuery.isNotEmpty ? cleanedQuery : userText,
          'match_count': 8,
          'filter_institution_id': currentInstId.isNotEmpty ? currentInstId : null,
          'filter_department': null,
        });

        if (chunksRes != null && (chunksRes as List).isNotEmpty) {
          final groqReply = await SupabaseService.queryGroqDirect(
            userText: userText,
            collegeName: college.name,
            isVerified: isVerified,
            student: student,
            conversationHistory: conversationHistory,
            institutionId: currentInstId,
          );

          if (groqReply != null && groqReply.isNotEmpty) {
            String responseText = groqReply;
            Map<String, dynamic>? attachedPayload;

            final attachDocRegex = RegExp(r'\[ATTACH_DOC:(.*?)\]');
            final match = attachDocRegex.firstMatch(responseText);
            if (match != null) {
              final docId = match.group(1)?.trim();
              responseText = responseText.replaceAll(attachDocRegex, '').trim();

              if (docId != null && docId.isNotEmpty) {
                try {
                  final docFetch = await SupabaseService.client!
                      .from('documents')
                      .select('*')
                      .eq('id', docId)
                      .maybeSingle();
                  if (docFetch != null) {
                    attachedPayload = {
                      'fileUrl': docFetch['file_url'],
                      'title': docFetch['title'],
                      'category': (docFetch['category'] ?? 'DOCUMENT').toString().replaceAll('_', ' ').toUpperCase(),
                      'subject': docFetch['subject_name'] ?? '',
                      'department': docFetch['department'] ?? '',
                      'semester': docFetch['semester'] ?? '',
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
              dataType: attachedPayload != null ? ChatDataType.timetable : ChatDataType.none,
              payload: attachedPayload,
            );
          }
        }
      } catch (e) {
        // Fallback to Groq Direct AI
      }
    }

    // 4. Direct Groq AI API Call with Multi-Turn History & Anti-Hallucination
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

    // 5. Legacy Hardcoded Academic Solver (Fallback for pre-indexed content)
    if (isQuestionAnsweringRequest) {
      String activeSubject = 'Fundamentals of Blockchain (FBC)';
      String activeDocTitle = 'Academic Assignment';

      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        for (final msg in conversationHistory.reversed) {
          if (msg.payload != null) {
            final pSubj = msg.payload!['subject']?.toString();
            final pTitle = msg.payload!['title']?.toString();
            if (pSubj != null && pSubj.isNotEmpty) activeSubject = pSubj;
            if (pTitle != null && pTitle.isNotEmpty) activeDocTitle = pTitle;
            break;
          }
        }
      }

      final String lang = isGujarati ? 'GUJARATI' : 'ENGLISH';
      final academicAnswer = AcademicSolverService.solveAssignmentQuestion(
        userText: userText,
        activeSubject: activeSubject,
        activeDocumentTitle: activeDocTitle,
        language: lang,
      );

      if (academicAnswer != null && academicAnswer.isNotEmpty) {
        return ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: ChatSender.ai,
          text: academicAnswer,
          timestamp: DateTime.now(),
          dataType: ChatDataType.none,
        );
      }
    }

    // 4. Fallback processor
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

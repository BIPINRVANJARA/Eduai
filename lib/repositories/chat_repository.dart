import '../core/services/academic_solver_service.dart';
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

    // 2. RAG Full-Text Search for Question Answering (Primary Retrieval)
    final String currentInstId = (student?.collegeId.isNotEmpty == true
            ? student!.collegeId
            : college.id)
        .trim();

    if (isQuestionAnsweringRequest && SupabaseService.client != null) {
      try {
        final chunksRes = await SupabaseService.client!.rpc('search_document_chunks', params: {
          'query_text': userText,
          'match_count': 8,
          'filter_institution_id': currentInstId.isNotEmpty ? currentInstId : null,
          'filter_department': student?.department,
        });

        if (chunksRes != null && (chunksRes as List).isNotEmpty) {
          // RAG chunks found — route directly to Groq with real document content
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

            // Extract [ATTACH_DOC:<doc_id>] if present
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
        // Fallback to heuristic + Groq
      }
    }

    // 3. Heuristic Document Card Matching (for download/view requests like "give me timetable")
    if (!isStudentDataQuery && !isQuestionAnsweringRequest) {
      try {
        if (SupabaseService.client != null) {
          var docQuery = SupabaseService.client!.from('documents').select('*');
          if (currentInstId.isNotEmpty) {
            docQuery = docQuery.eq('institution_id', currentInstId);
          }

          final docsRes = await docQuery
              .order('created_at', ascending: false)
              .limit(50);

          final docsList = (docsRes as List?) ?? [];
          if (docsList.isNotEmpty) {
            Map<String, dynamic>? bestDoc;
            int highestScore = 0;

            // Extract query tokens & known acronyms
            final queryTokens = lower
                .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ')
                .split(RegExp(r'\s+'))
                .where((t) => t.isNotEmpty)
                .toSet();

            // Known subject keywords to isolate
            final knownSubjectKeywords = {
              'fbc', 'blockchain', 'aipd', 'aipe', 'prompt', 'dbms', 'dsa', 
              'cn', 'os', 'iot', 'cloud', 'cns', 'se', 'python', 'java', 
              'wt', 'wad', 'maths', 'math', 'physics', 'chemistry', 'cyber'
            };

            final activeQuerySubjects = queryTokens.intersection(knownSubjectKeywords);

            // Extract assignment / unit number in query (e.g. "fbc 1 assignment", "assignment 2", "fbc 1")
            int? queryNumber;
            final digitMatches = RegExp(r'\b([0-9]+)\b').allMatches(lower);
            for (final m in digitMatches) {
              final raw = m.group(1);
              if (raw != null) {
                final start = m.start;
                final prefix = lower.substring(0, start).trim();
                // Ignore semester numbers like "sem 5"
                if (!prefix.endsWith('sem') && !prefix.endsWith('semester') && !prefix.endsWith('સેમ')) {
                  queryNumber = int.tryParse(raw);
                  break;
                }
              }
            }

            for (final rawDoc in docsList) {
              final doc = Map<String, dynamic>.from(rawDoc);
              int score = 0;

              final title = (doc['title'] ?? '').toString().toLowerCase();
              final category = (doc['category'] ?? '').toString().toLowerCase();
              final dept = (doc['department'] ?? '').toString().toLowerCase();
              final sem = (doc['semester'] ?? '').toString().toLowerCase();
              final subject = (doc['subject_name'] ?? '').toString().toLowerCase();
              final tags = (doc['tags'] as List?)?.map((t) => t.toString().toLowerCase()).toList() ?? [];

              final docSubjectText = '$title $subject ${tags.join(' ')}';

              // === A. STRICT SUBJECT MATCHING ===
              if (activeQuerySubjects.isNotEmpty) {
                bool matchedSubject = false;
                for (final subjKey in activeQuerySubjects) {
                  if (docSubjectText.contains(subjKey)) {
                    score += 300;
                    matchedSubject = true;
                  }
                }
                // If query specified a known subject and this doc doesn't have it -> PENALTY
                if (!matchedSubject) {
                  score -= 400;
                }
              }

              // === B. ASSIGNMENT / UNIT NUMBER MATCHING ===
              if (queryNumber != null) {
                final docHasNumber = title.contains('assignment $queryNumber') ||
                    title.contains('assignment$queryNumber') ||
                    title.contains('unit $queryNumber') ||
                    title.contains(' $queryNumber ') ||
                    title.contains(' $queryNumber-') ||
                    title.contains(' $queryNumber -') ||
                    tags.any((t) => t.contains('assignment $queryNumber') || t.contains('unit $queryNumber') || t == '$queryNumber');

                if (docHasNumber) {
                  score += 150;
                } else {
                  score -= 100;
                }
              }

              // === C. CATEGORY & INTENT MATCHING ===
              final isTTIntent = lower.contains('timetable') ||
                  lower.contains('time table') ||
                  lower.contains('schedule') ||
                  lower.contains('tt') ||
                  lower.contains('સમયપત્રક') ||
                  lower.contains('ટાઈમટેબલ') ||
                  lower.contains('समय सारणी');

              final isLabIntent = lower.contains('lab') ||
                  lower.contains('manual') ||
                  lower.contains('practical') ||
                  lower.contains('લેબ') ||
                  lower.contains('મેન્યુઅલ') ||
                  lower.contains('પુસ્તિકા');

              final isAssignIntent = lower.contains('assignment') ||
                  lower.contains('homework') ||
                  lower.contains('problem set') ||
                  lower.contains('એસાઇનમેન્ટ') ||
                  lower.contains('એસાઈનમેન્ટ') ||
                  lower.contains('સ્વાધ્યાય') ||
                  lower.contains('હોમવર્ક');

              final isCircularIntent = lower.contains('circular') ||
                  lower.contains('notice') ||
                  lower.contains('પરિપત્ર') ||
                  lower.contains('નોટિસ');

              final isSyllabusIntent = lower.contains('syllabus') ||
                  lower.contains('curriculum') ||
                  lower.contains('અભ્યાસક્રમ');

              if (category == 'timetable' && isTTIntent) {
                score += 50;
              } else if (category == 'lab_manual' && isLabIntent) {
                score += 50;
              } else if (category == 'assignment' && isAssignIntent) {
                score += 50;
              } else if (category == 'circular' && isCircularIntent) {
                score += 50;
              } else if (category == 'syllabus' && isSyllabusIntent) {
                score += 50;
              }

              // === D. TAG & TITLE MATCHING ===
              for (final tag in tags) {
                if (tag.isNotEmpty && (lower.contains(tag) || tag.contains(lower))) {
                  score += 20;
                }
              }

              if (title.isNotEmpty && (lower.contains(title) || title.contains(lower))) score += 25;
              if (subject.isNotEmpty && (lower.contains(subject) || subject.contains(lower))) score += 25;

              // === E. DEPARTMENT & SEMESTER MATCHING ===
              if (score > 0 && dept.isNotEmpty) {
                if ((lower.contains('it') || lower.contains('information')) &&
                    (dept.contains('information technology') || dept.contains('it'))) {
                  score += 10;
                } else if (student != null && student.branch.toLowerCase().contains(dept)) {
                  score += 5;
                }
              }

              if (score > 0 && sem.isNotEmpty) {
                final semTokens = sem.replaceAll(RegExp(r'[^0-9]'), ' ').split(' ').where((s) => s.trim().isNotEmpty);
                for (final s in semTokens) {
                  if (lower.contains('sem $s') || lower.contains('semester $s') || lower.contains('સેમ $s') || lower.contains('sem$s')) {
                    score += 15;
                  }
                }
              }

              if (score > highestScore) {
                highestScore = score;
                bestDoc = doc;
              }
            }

            // Confident document match found (score >= 40)
            if (bestDoc != null && highestScore >= 40) {
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

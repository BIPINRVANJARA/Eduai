import '../core/services/academic_solver_service.dart';
import '../core/services/supabase_service.dart';
import '../core/services/timetable_service.dart';
import '../models/chat_message_model.dart';
import '../models/college_model.dart';
import '../models/student_model.dart';

class ChatRepository {
  static final Set<String> _conversationalWords = {
    'give', 'me', 'please', 'show', 'tell', 'send', 'share', 'can', 'you',
    'i', 'need', 'want', 'where', 'is', 'the', 'what', 'whats', "what's", 'a', 'an', 'of',
    'for', 'about', 'with', 'pdf', 'file', 'document', 'download', 'view', 'get',
    'my', 'our', 'when', 'whens', "when's", 'how', 'which', 'are', 'was', 'were',
    'will', 'be', 'on', 'at', 'to', 'in', 'has', 'have', 'do', 'does', 'did',
    'krupya', 'aapo', 'moklo', 'batavo', 'de', 'aap', 'maru', 'maro', 'mari',
    'kyare', 'che', 'kaho', 'janavo'
  };

  static bool _isValidUuid(String? str) {
    if (str == null || str.trim().isEmpty) return false;
    return RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(str.trim());
  }

  static String _cleanSearchQuery(String text) {
    String normalized = text.toLowerCase()
        .replaceAll(RegExp(r'\b1st\b'), '1')
        .replaceAll(RegExp(r'\b2nd\b'), '2')
        .replaceAll(RegExp(r'\b3rd\b'), '3')
        .replaceAll(RegExp(r'\b4th\b'), '4')
        .replaceAll(RegExp(r'\b5th\b'), '5')
        .replaceAll(RegExp(r'\b6th\b'), '6')
        .replaceAll(RegExp(r'\b(?:que|question|qu|q|prashna|પ્રશ્ન)\s*[0-9]+\b'), '')
        .replaceAll(RegExp(r'\b(?:ans|answer|solve|solution|જવાબ|ઉકેલ)\b'), '');

    final tokens = normalized
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s\u0A80-\u0AFF\u0900-\u097F]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty && !_conversationalWords.contains(t))
        .toList();
    return tokens.isNotEmpty ? tokens.join(' ') : text;
  }

  static String _getSubjectFullName(String code) {
    switch (code.toLowerCase()) {
      case 'aipd':
        return 'Artificial Intelligence & Product Development (AIPD)';
      case 'aipe':
        return 'Artificial Intelligence & Prompt Engineering (AIPE)';
      case 'fbc':
        return 'Fundamentals of Blockchain (FBC)';
      case 'cdct':
        return 'Cloud and Data Center Technology (CDCT)';
      case 'dbms':
        return 'Database Management Systems (DBMS)';
      case 'cn':
        return 'Computer Networks (CN)';
      case 'os':
        return 'Operating Systems (OS)';
      default:
        return code.toUpperCase();
    }
  }

  static Map<String, dynamic> _parseAcademicIntent(String text) {
    final lower = text.toLowerCase();

    // 1. Detect Subject
    String? subject;
    if (lower.contains('aipd') || lower.contains('product development') || lower.contains('ai product')) {
      subject = 'aipd';
    } else if (lower.contains('aipe') || lower.contains('prompt engineering') || lower.contains('prompt')) {
      subject = 'aipe';
    } else if (lower.contains('fbc') || lower.contains('blockchain')) {
      subject = 'fbc';
    } else if (lower.contains('cdct') || lower.contains('cloud') || lower.contains('data center')) {
      subject = 'cdct';
    } else if (lower.contains('dbms') || lower.contains('database')) {
      subject = 'dbms';
    }

    // 2. Detect Assignment / Unit Number
    int? assignmentNum;
    final assignMatch = RegExp(r'(?:assignment|unit|unit-)\s*([0-9]+)').firstMatch(lower) ??
        RegExp(r'([0-9]+)(?:st|nd|rd|th)\s*assignment').firstMatch(lower) ??
        RegExp(r'([0-9]+)\s*assignment').firstMatch(lower);
    if (assignMatch != null && assignMatch.group(1) != null) {
      assignmentNum = int.tryParse(assignMatch.group(1)!);
    }

    // 3. Detect Question Number
    int? questionNum;
    final qMatch = RegExp(r'(?:que|question|qu|q|prashna|પ્રશ્ન)\s*([0-9]+)').firstMatch(lower);
    if (qMatch != null && qMatch.group(1) != null) {
      questionNum = int.tryParse(qMatch.group(1)!);
    }

    // 4. Detect Exam Schedule / Timetable Intent
    final bool isExam = lower.contains('exam') ||
        lower.contains('mid sem') ||
        lower.contains('mid-sem') ||
        lower.contains('midsem') ||
        lower.contains('પરીક્ષા') ||
        (lower.contains('schedule') && !lower.contains('class')) ||
        (lower.contains('time table') && lower.contains('exam')) ||
        (lower.contains('timetable') && lower.contains('exam'));

    final bool isTT = isExam ||
        lower.contains('timetable') ||
        lower.contains('time table') ||
        lower.contains('schedule') ||
        lower.contains('સમયપત્રક') ||
        lower.contains('ટાઈમટેબલ') ||
        lower.contains('tt');

    return {
      'subject': subject,
      'assignmentNumber': assignmentNum,
      'questionNumber': questionNum,
      'isExamSchedule': isExam,
      'isTimetable': isTT,
    };
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

    // ═══════════════════════════════════════════════════════════════════
    // DOCUMENT-INTENT OVERRIDE: If the query contains a document-type
    // keyword, it MUST NOT be classified as a personal data query, even
    // if it also contains words like "gtu", "marks", "internal", etc.
    // This fixes: "i need gtu syllabus of aipe" → was going to attendance
    // ═══════════════════════════════════════════════════════════════════
    final bool hasDocumentIntent = lower.contains('syllabus') ||
        lower.contains('curriculum') ||
        lower.contains('અભ્યાસક્રમ') ||
        lower.contains('પાઠ્યક્રમ') ||
        lower.contains('lab manual') ||
        lower.contains('labmanual') ||
        lower.contains('assignment') ||
        lower.contains('એસાઇનમેન્ટ') ||
        lower.contains('timetable') ||
        lower.contains('time table') ||
        lower.contains('schedule') ||
        lower.contains('exam') ||
        lower.contains('notes') ||
        lower.contains('circular') ||
        lower.contains('notice') ||
        lower.contains('pdf') ||
        lower.contains('download') ||
        lower.contains('lab book');

    // Explanation-type keywords (user wants conceptual answer, NOT personal data)
    final bool wantsExplanation = lower.contains('what is') ||
        lower.contains('how to') ||
        lower.contains('explain') ||
        lower.contains('define') ||
        lower.contains('describe') ||
        lower.contains('difference between') ||
        lower.contains('compare') ||
        lower.contains('advantages') ||
        lower.contains('disadvantages') ||
        lower.contains('સમજાવો') ||
        lower.contains('समझाएं');

    final bool isStudentDataQuery = !hasDocumentIntent && !wantsExplanation && (
        lower.contains('attendance') ||
        lower.contains('attendence') ||
        lower.contains('percentage') ||
        lower.contains('eligibility') ||
        lower.contains('eligible') ||
        lower.contains('defaulter') ||
        lower.contains('હાજરી') ||
        lower.contains('mark') ||
        lower.contains('marks') ||
        lower.contains('માર્ક્સ') ||
        lower.contains('માર્ક') ||
        lower.contains('result') ||
        lower.contains('પરિણામ') ||
        lower.contains('grade'));

    final bool isQuestionAnsweringRequest = (
        lower.contains('que') ||
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
        lower.contains('समझाएं'));

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
    final String rawInstId = (student?.collegeId.isNotEmpty == true
            ? student!.collegeId
            : college.id)
        .trim();

    final String? currentInstId = _isValidUuid(rawInstId)
        ? rawInstId
        : (rawInstId.toLowerCase().contains('gph') || college.code == '624' || college.name.toLowerCase().contains('himmatnagar')
            ? '6c6e9b83-cabf-4b13-855b-97d2e1461177'
            : null);

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
        lower.contains('manual') ||
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

    final academicIntent = _parseAcademicIntent(userText);
    final String? intentSubject = academicIntent['subject'] as String?;
    final int? intentAssignNum = academicIntent['assignmentNumber'] as int?;
    final bool isExamSchedule = academicIntent['isExamSchedule'] == true;

    final bool isExplicitClassTT = lower.contains('class timetable') ||
        lower.contains('class time table') ||
        lower.contains('class schedule') ||
        lower.contains('lecture timetable') ||
        lower.contains('lecture schedule') ||
        lower.contains('weekly timetable') ||
        lower.contains('regular timetable');

    // ═══════════════════════════════════════════════════════════════════
    // A0. REAL-TIME CURRENT LECTURE & DAILY CLASS TIMETABLE SOLVER
    // (Extracted from official IT Department Timetable Excel for Sem 1, 3, 5)
    // ═══════════════════════════════════════════════════════════════════
    final bool isCurrentLectureQuery = lower.contains('current lecture') ||
        lower.contains('current class') ||
        lower.contains('lecture now') ||
        lower.contains('class now') ||
        lower.contains('which lecture') ||
        lower.contains('what lecture') ||
        lower.contains('next lecture') ||
        lower.contains('next class') ||
        lower.contains('going on') ||
        (lower.contains('right now') && (lower.contains('lecture') || lower.contains('class') || lower.contains('lab'))) ||
        (lower.contains('હમણાં') && (lower.contains('લેક્ચર') || lower.contains('ક્લાસ') || lower.contains('ચાલુ'))) ||
        lower.contains('ચાલુ લેક્ચર') ||
        lower.contains('હવે કયો લેક્ચર');

    final bool isDailyTimetableQuery = isExplicitClassTT ||
        lower.contains("today's timetable") ||
        lower.contains("today timetable") ||
        lower.contains("today's schedule") ||
        lower.contains("today schedule") ||
        lower.contains("tomorrow's timetable") ||
        lower.contains("tomorrow timetable") ||
        lower.contains("tomorrow schedule") ||
        lower.contains("monday timetable") ||
        lower.contains("tuesday timetable") ||
        lower.contains("wednesday timetable") ||
        lower.contains("thursday timetable") ||
        lower.contains("friday timetable") ||
        lower.contains("આજનો ટાઈમટેબલ") ||
        lower.contains("આજનો સમયપત્રક") ||
        lower.contains("આવતીકાલનો ટાઈમટેબલ") ||
        ((lower.contains('timetable') || lower.contains('time table')) &&
         !lower.contains('exam') &&
         !lower.contains('mid') &&
         !lower.contains('પરીક્ષા'));

    if (isCurrentLectureQuery) {
      final String lang = isGujarati ? 'GUJARATI' : 'ENGLISH';
      final responseText = TimetableService.getCurrentLectureResponse(
        userText: userText,
        studentSemester: student?.semester ?? 5,
        language: lang,
      );

      return ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: ChatSender.ai,
        text: responseText,
        timestamp: DateTime.now(),
        dataType: ChatDataType.timetable,
        payload: {
          'title': 'IT Department Real-Time Class Schedule',
          'category': 'TIMETABLE',
          'department': 'Information Technology',
          'semester': (student?.semester ?? 5).toString(),
        },
      );
    }

    if (isDailyTimetableQuery) {
      final String lang = isGujarati ? 'GUJARATI' : 'ENGLISH';
      final responseText = TimetableService.getDailyScheduleResponse(
        userText: userText,
        studentSemester: student?.semester ?? 5,
        language: lang,
      );

      return ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: ChatSender.ai,
        text: responseText,
        timestamp: DateTime.now(),
        dataType: ChatDataType.timetable,
        payload: {
          'title': 'IT Department Daily Class Timetable',
          'category': 'TIMETABLE',
          'department': 'Information Technology',
          'semester': (student?.semester ?? 5).toString(),
        },
      );
    }

    // A. Priority Exam Schedule & Timetable Resolver (Direct zero-hallucination table + PDF card)

    final bool isExamScheduleQuery = !isExplicitClassTT && (
        isExamSchedule ||
        lower.contains('exam schedule') ||
        lower.contains('exam timetable') ||
        lower.contains('exam time table') ||
        lower.contains('exam date') ||
        lower.contains('exam time') ||
        lower.contains('exam timing') ||
        lower.contains('mid sem') ||
        lower.contains('mid-sem') ||
        lower.contains('midsem') ||
        lower.contains('પરીક્ષા') ||
        (lower.contains('exam') && (
          lower.contains('schedule') ||
          lower.contains('when') ||
          lower.contains('date') ||
          lower.contains('time') ||
          lower.contains('timetable') ||
          lower.contains('timing') ||
          lower.contains('day') ||
          lower.contains('table')
        )) ||
        (lower.contains('schedule') && (
          lower.contains('my') ||
          lower.contains('our') ||
          lower.contains('it') ||
          lower.contains('sem 5') ||
          lower.contains('sem-5') ||
          lower.contains('semester 5')
        ))
    );

    if (isExamScheduleQuery) {
      final String lang = isGujarati ? 'GUJARATI' : 'ENGLISH';
      final examText = AcademicSolverService.getExamScheduleResponse(
        userText: userText,
        language: lang,
        specificSubject: intentSubject,
      );

      // Fetch the official exam timetable document for the attachment card
      Map<String, dynamic>? examDoc;
      if (SupabaseService.client != null) {
        try {
          final byId = await SupabaseService.client!
              .from('documents')
              .select('*')
              .eq('id', '62d20e77-39e2-4dcc-b188-33141b4c9b80')
              .maybeSingle();

          if (byId != null) {
            examDoc = Map<String, dynamic>.from(byId);
          } else {
            final byQuery = await SupabaseService.client!
                .from('documents')
                .select('*')
                .ilike('category', '%timetable%')
                .ilike('title', '%exam%')
                .maybeSingle();
            if (byQuery != null) {
              examDoc = Map<String, dynamic>.from(byQuery);
            }
          }
        } catch (_) {}
      }

      final String fileUrl = examDoc?['file_url'] ??
          'https://ifframkwyjegmxubscnk.supabase.co/storage/v1/object/public/documents/sem5/id-Exam%20Sem%20-5%20Winter%202026%20Exam%20Time%20Table%20.pdf';
      final String docTitle = examDoc?['title'] ?? 'IT Sem 5 Mid-Sem Exam Schedule (Winter 2026)';
      final String dept = examDoc?['department'] ?? 'Information Technology';
      final String sem = examDoc?['semester'] ?? '5';

      return ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: ChatSender.ai,
        text: examText,
        timestamp: DateTime.now(),
        dataType: ChatDataType.timetable,
        payload: {
          'fileUrl': fileUrl,
          'title': docTitle,
          'category': 'TIMETABLE',
          'subject': 'IT Semester 5 Exam Schedule',
          'department': dept,
          'semester': sem,
        },
      );
    }

    // B. Priority Syllabus Resolver (dedicated deterministic GTU syllabus solver + official PDF)
    final bool isSyllabusQuery = lower.contains('syllabus') ||
        lower.contains('curriculum') ||
        lower.contains('અભ્યાસક્રમ') ||
        lower.contains('પાઠ્યક્રમ');

    if (isSyllabusQuery) {
      final String lang = isGujarati ? 'GUJARATI' : 'ENGLISH';
      final syllabusText = AcademicSolverService.getSyllabusResponse(
        userText: userText,
        language: lang,
        specificSubject: intentSubject,
      );

      // Fetch the official syllabus document for the attachment card
      Map<String, dynamic>? syllabusDoc;
      if (SupabaseService.client != null) {
        try {
          final byId = await SupabaseService.client!
              .from('documents')
              .select('*')
              .eq('id', '72e9a99e-afb3-4143-bc4e-fa7f5211176f')
              .maybeSingle();

          if (byId != null) {
            syllabusDoc = Map<String, dynamic>.from(byId);
          } else {
            final byQuery = await SupabaseService.client!
                .from('documents')
                .select('*')
                .ilike('category', '%syllabus%')
                .ilike('title', '%mid%')
                .maybeSingle();
            if (byQuery != null) {
              syllabusDoc = Map<String, dynamic>.from(byQuery);
            }
          }
        } catch (_) {}
      }

      final String fileUrl = syllabusDoc?['file_url'] ??
          'https://ifframkwyjegmxubscnk.supabase.co/storage/v1/object/public/documents/sem5/sem%205%20_mid%20syllabus_SEP-2026.pdf';
      final String subjectDisplay = intentSubject != null ? _getSubjectFullName(intentSubject) : 'Information Technology Sem 5';
      final String docTitle = syllabusDoc?['title'] ?? 'GTU IT Sem 5 Mid-Sem Syllabus (Winter 2026)';
      final String dept = syllabusDoc?['department'] ?? 'Information Technology';
      final String sem = syllabusDoc?['semester'] ?? '5';

      return ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: ChatSender.ai,
        text: syllabusText,
        timestamp: DateTime.now(),
        dataType: ChatDataType.timetable,
        payload: {
          'fileUrl': fileUrl,
          'title': docTitle,
          'category': 'SYLLABUS',
          'subject': subjectDisplay,
          'department': dept,
          'semester': sem,
        },
      );
    }

    // C. Priority Lab Manual Resolver (dedicated category-aware search)
    final bool isLabManualQuery = lower.contains('lab manual') ||
        lower.contains('labmanual') ||
        lower.contains('lab book') ||
        lower.contains('લેબ મેન્યુઅલ') ||
        (lower.contains('practical') && (lower.contains('manual') || lower.contains('book') || lower.contains('pdf')));

    if (isLabManualQuery && !isQuestionAnsweringRequest && SupabaseService.client != null) {
      try {
        var labQuery = SupabaseService.client!
            .from('documents')
            .select('*')
            .eq('category', 'lab_manual');

        if (currentInstId != null) {
          labQuery = labQuery.eq('institution_id', currentInstId);
        }

        final labResults = await labQuery.order('title');

        if ((labResults as List).isNotEmpty) {
          List<Map<String, dynamic>> matchedDocs = [];

          if (intentSubject != null) {
            final subjectFullName = _getSubjectFullName(intentSubject).toLowerCase();
            final code = intentSubject.toLowerCase();

            matchedDocs = labResults.cast<Map<String, dynamic>>().where((doc) {
              final title = (doc['title'] ?? '').toString().toLowerCase();
              final subject = (doc['subject_name'] ?? '').toString().toLowerCase();
              return title.contains(code) || subject.contains(code) ||
                     title.contains(subjectFullName) || subject.contains(subjectFullName);
            }).toList();
          } else {
            matchedDocs = labResults.cast<Map<String, dynamic>>();
          }

          if (matchedDocs.isNotEmpty) {
            final buffer = StringBuffer();
            final subjectDisplay = intentSubject != null
                ? _getSubjectFullName(intentSubject)
                : (matchedDocs.first['subject_name'] ?? 'your subject');
            final primaryDoc = matchedDocs.first;
            final dept = primaryDoc['department'] ?? 'Information Technology';
            final sem = primaryDoc['semester'] ?? '5';

            if (isGujarati) {
              buffer.writeln('📚 **$subjectDisplay** ($dept સેમેસ્ટર $sem) માટેની લેબ મેન્યુઅલ:');
            } else {
              buffer.writeln('Here is the **Lab Manual** for **$subjectDisplay** ($dept Sem $sem):');
            }

            if (matchedDocs.length > 1) {
              buffer.writeln('');
              if (isGujarati) {
                buffer.writeln('કુલ **${matchedDocs.length}** લેબ મેન્યુઅલ ઉપલબ્ધ છે:\n');
              } else {
                buffer.writeln('**${matchedDocs.length}** lab manuals available:\n');
              }
              for (int i = 0; i < matchedDocs.length; i++) {
                buffer.writeln('${i + 1}. **${matchedDocs[i]['title']}**');
              }
            }

            return ChatMessageModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              sender: ChatSender.ai,
              text: buffer.toString().trim(),
              timestamp: DateTime.now(),
              dataType: ChatDataType.none,
              payload: {
                'fileUrl': primaryDoc['file_url'],
                'title': primaryDoc['title'],
                'category': 'LAB MANUAL',
                'subject': primaryDoc['subject_name'] ?? subjectDisplay,
                'department': dept,
                'semester': sem,
              },
            );
          }
        }
      } catch (_) {}
    }

    // D. Priority RAG Document Attachment (When user asks for a document / timetable / assignment)
    if (isDocFetchIntent && !isQuestionAnsweringRequest && SupabaseService.client != null) {
      try {
        Map<String, dynamic>? targetDoc;

        // 1. Exact Precision Matching for Subject + Assignment (e.g. "aipd 3rd assignment", "fbc 2nd assignment")
        if (intentSubject != null && intentAssignNum != null) {
          final directDocsRes = await SupabaseService.client!
              .from('documents')
              .select('*')
              .ilike('category', '%assignment%')
              .ilike('title', '%$intentSubject%');

          if (directDocsRes.isNotEmpty) {
            final match = directDocsRes.cast<Map<String, dynamic>>().firstWhere(
              (d) {
                final t = (d['title'] ?? '').toString().toLowerCase();
                return t.contains('assignment $intentAssignNum') ||
                    t.contains('assignment-$intentAssignNum') ||
                    t.contains('unit $intentAssignNum') ||
                    t.contains('unit-$intentAssignNum');
              },
              orElse: () => {},
            );
            if (match.isNotEmpty) {
              targetDoc = match;
            }
          }

          // If the user explicitly requested Assignment X for Subject Y, and it does NOT exist in DB (e.g. AIPD Assignment 3),
          // DO NOT attach an unrelated assignment! Return the helpful missing message immediately!
          if (targetDoc == null) {
            final String subName = _getSubjectFullName(intentSubject);
            final String notFoundMsg = isGujarati
                ? 'ક્ષમા કરશો, **$subName** માટે **Assignment $intentAssignNum** હજી સુધી અપલોડ થયો નથી. હાલમાં ઉપલબ્ધ એસાઇનમેન્ટ તપાસો અથવા ફેકલ્ટીનો સંપર્ક કરો.'
                : 'I searched the campus repository, but **Assignment $intentAssignNum** for **$subName** is not uploaded yet. Currently, **Assignment 1** and **Assignment 2** are available. Would you like to view Assignment 1 or 2?';
            return ChatMessageModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              sender: ChatSender.ai,
              text: notFoundMsg,
              timestamp: DateTime.now(),
              dataType: ChatDataType.none,
            );
          }
        }

        // 2. Standard Chunk Search (for timetables, lab manuals, or general queries)
        if (targetDoc == null) {
          final chunksRes = await SupabaseService.client!.rpc('search_document_chunks', params: {
            'query_text': cleanedQuery.isNotEmpty ? cleanedQuery : userText,
            'match_count': 3,
            'filter_institution_id': currentInstId,
            'filter_department': null,
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
                if (intentAssignNum != null) {
                  final t = (docFetch['title'] ?? '').toString().toLowerCase();
                  if (t.contains('assignment $intentAssignNum') ||
                      t.contains('assignment-$intentAssignNum') ||
                      t.contains('unit $intentAssignNum') ||
                      t.contains('unit-$intentAssignNum')) {
                    targetDoc = Map<String, dynamic>.from(docFetch);
                  }
                } else {
                  targetDoc = Map<String, dynamic>.from(docFetch);
                }
              }
            }
          }
        }

        if (targetDoc != null) {
          final cat = (targetDoc['category'] ?? 'document').toString();
          final title = targetDoc['title'] ?? 'Academic Document';
          final dept = targetDoc['department'] ?? '';
          final sem = targetDoc['semester'] ?? '';
          final subject = targetDoc['subject_name'] ?? '';

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

          final docDesc = (targetDoc['description'] ?? targetDoc['content_summary'] ?? '').toString().trim();
          if (docDesc.isNotEmpty && !docDesc.startsWith('This document contains the class')) {
            label += '\n\n$docDesc';
          }

          return ChatMessageModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sender: ChatSender.ai,
            text: label,
            timestamp: DateTime.now(),
            dataType: cat == 'timetable' ? ChatDataType.timetable : ChatDataType.none,
            payload: {
              'fileUrl': targetDoc['file_url'],
              'title': title,
              'category': categoryDisplay,
              'subject': subject,
              'department': dept,
              'semester': sem,
            },
          );
        }
      } catch (e) {
        // Fallback to Groq AI
      }
    }

    // B. Academic Question Answering (GTU Direct Solver + RAG Groq)
    if (isQuestionAnsweringRequest) {
      // 1. High-Precision Direct Solver: If user asks for an assignment question
      // (e.g. "fbc 2nd assignment que 1 ans", "aipd 1st assignment qu1 ans")
      Map<String, dynamic>? matchingDoc;
      if (SupabaseService.client != null && intentSubject != null) {
        try {
          final directDocsRes = await SupabaseService.client!
              .from('documents')
              .select('*')
              .ilike('category', '%assignment%')
              .ilike('title', '%$intentSubject%');

          if (directDocsRes.isNotEmpty) {
            if (intentAssignNum != null) {
              final match = directDocsRes.cast<Map<String, dynamic>>().firstWhere(
                (d) {
                  final t = (d['title'] ?? '').toString().toLowerCase();
                  return t.contains('assignment $intentAssignNum') ||
                      t.contains('assignment-$intentAssignNum') ||
                      t.contains('unit $intentAssignNum') ||
                      t.contains('unit-$intentAssignNum');
                },
                orElse: () => {},
              );
              if (match.isNotEmpty) matchingDoc = match;
            } else {
              matchingDoc = Map<String, dynamic>.from(directDocsRes.first);
            }
          }
        } catch (_) {}
      }

      final String solverSubject = matchingDoc?['subject_name'] ??
          (intentSubject != null ? _getSubjectFullName(intentSubject) : 'Information Technology');
      final String solverTitle = matchingDoc?['title'] ??
          (intentAssignNum != null ? 'Assignment $intentAssignNum' : '');

      final academicAnswer = AcademicSolverService.solveAssignmentQuestion(
        userText: userText,
        activeSubject: solverSubject,
        activeDocumentTitle: solverTitle,
        language: isGujarati ? 'GUJARATI' : 'ENGLISH',
      );

      // If AcademicSolverService has a specific, non-generic GTU answer, return it immediately with the PDF attached!
      final bool isSpecificAnswer = academicAnswer.isNotEmpty &&
          !academicAnswer.contains('Assignment Solution\n\n**1. Subject Overview:**');

      if (isSpecificAnswer) {
        Map<String, dynamic>? attachedPayload;
        if (matchingDoc != null) {
          attachedPayload = {
            'fileUrl': matchingDoc['file_url'],
            'title': matchingDoc['title'],
            'category': (matchingDoc['category'] ?? 'ASSIGNMENT').toString().replaceAll('_', ' ').toUpperCase(),
            'subject': matchingDoc['subject_name'] ?? solverSubject,
            'department': matchingDoc['department'] ?? '',
            'semester': matchingDoc['semester'] ?? '',
          };
        } else if (intentSubject != null) {
          final sName = _getSubjectFullName(intentSubject);
          attachedPayload = {
            'fileUrl': '',
            'title': '$sName ${intentAssignNum != null ? 'Assignment $intentAssignNum' : 'Assignment'}',
            'category': 'ASSIGNMENT',
            'subject': sName,
            'department': 'Information Technology',
            'semester': '5',
          };
        }

        return ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: ChatSender.ai,
          text: academicAnswer,
          timestamp: DateTime.now(),
          dataType: attachedPayload != null ? ChatDataType.timetable : ChatDataType.none,
          payload: attachedPayload,
        );
      }

      // 2. Groq AI RAG with retrieved chunks (for general or conceptual questions)
      if (SupabaseService.client != null) {
        try {
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

            if (attachedPayload == null && matchingDoc != null) {
              attachedPayload = {
                'fileUrl': matchingDoc['file_url'],
                'title': matchingDoc['title'],
                'category': (matchingDoc['category'] ?? 'ASSIGNMENT').toString().replaceAll('_', ' ').toUpperCase(),
                'subject': matchingDoc['subject_name'] ?? solverSubject,
                'department': matchingDoc['department'] ?? '',
                'semester': matchingDoc['semester'] ?? '',
              };
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
        } catch (_) {}
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

    // 5. Dynamic Subject-Aware Academic Solver Fallback
    if (isQuestionAnsweringRequest) {
      String activeSubject = 'Information Technology';
      String activeDocTitle = 'Academic Assignment';

      final qLower = userText.toLowerCase();
      if (qLower.contains('aipd') || qLower.contains('product development')) {
        activeSubject = 'Artificial Intelligence and Product Development (AIPD)';
      } else if (qLower.contains('aipe') || qLower.contains('prompt')) {
        activeSubject = 'Artificial Intelligence and Prompt Engineering (AIPE)';
      } else if (qLower.contains('cdct') || qLower.contains('cloud') || qLower.contains('data center')) {
        activeSubject = 'Cloud and Data Center Technology (CDCT)';
      } else if (qLower.contains('fbc') || qLower.contains('blockchain')) {
        activeSubject = 'Fundamentals of Blockchain (FBC)';
      } else if (qLower.contains('dbms') || qLower.contains('database')) {
        activeSubject = 'Database Management Systems (DBMS)';
      } else if (conversationHistory != null && conversationHistory.isNotEmpty) {
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

      if (academicAnswer.isNotEmpty) {
        return ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: ChatSender.ai,
          text: academicAnswer,
          timestamp: DateTime.now(),
          dataType: ChatDataType.none,
        );
      }
    }

    // 6. Helpful Not-Found Handler for Specific Document Requests
    if (isDocFetchIntent) {
      String subjectHint = 'the requested subject';
      if (lower.contains('aipd')) {
        subjectHint = 'Artificial Intelligence & Product Development (AIPD)';
      } else if (lower.contains('aipe')) {
        subjectHint = 'Artificial Intelligence & Prompt Engineering (AIPE)';
      } else if (lower.contains('fbc') || lower.contains('blockchain')) {
        subjectHint = 'Fundamentals of Blockchain (FBC)';
      } else if (lower.contains('cdct') || lower.contains('cloud') || lower.contains('data center')) {
        subjectHint = 'Cloud and Data Center Technology (CDCT)';
      }

      final String missingMsg = isGujarati
          ? 'ક્ષમા કરશો, **$subjectHint** માટે માંગેલ દસ્તાવેજ હજી સુધી રિપોઝીટરીમાં અપલોડ થયો નથી. ઉપલબ્ધ એસાઇનમેન્ટ (Assignment 1 અને 2) તપાસો અથવા તમારા ફેકલ્ટીનો સંપર્ક કરો.'
          : 'I searched the campus repository, but that specific document for **$subjectHint** is not uploaded yet. Currently, **Assignment 1** and **Assignment 2** are available. Would you like to view Assignment 1 or 2?';

      return ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: ChatSender.ai,
        text: missingMsg,
        timestamp: DateTime.now(),
        dataType: ChatDataType.none,
      );
    }

    // 7. Fallback processor
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

    // Check for private / student-specific intent (Only personal student records require verification)
    final isPrivateIntent = text.contains('attendance') ||
        text.contains('mark') ||
        text.contains('result') ||
        text.contains('grade') ||
        text.contains('fee') ||
        text.contains('due') ||
        text.contains('son') ||
        text.contains('daughter') ||
        text.contains('child') ||
        text.contains('હાજરી') ||
        text.contains('પરિણામ') ||
        text.contains('માર્ક્સ');

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

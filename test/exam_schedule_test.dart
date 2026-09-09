import 'package:flutter_test/flutter_test.dart';
import 'package:parent_ai/core/services/academic_solver_service.dart';
import 'package:parent_ai/repositories/chat_repository.dart';
import 'package:parent_ai/models/college_model.dart';
import 'package:parent_ai/models/chat_message_model.dart';

void main() {
  group('Exam Schedule Solver Tests', () {
    test('General exam schedule returns complete timetable table', () {
      final res = AcademicSolverService.getExamScheduleResponse(
        userText: 'whats my exam schedule?',
        language: 'ENGLISH',
      );

      expect(res.contains('IT (Information Technology) — Semester 5 Mid-Sem Examination Schedule'), isTrue);
      expect(res.contains('11:30 AM – 12:30 PM'), isTrue);
      expect(res.contains('28-09-2026'), isTrue);
      expect(res.contains('29-09-2026'), isTrue);
      expect(res.contains('30-09-2026'), isTrue);
      expect(res.contains('01-10-2026'), isTrue);
      expect(res.contains('AIPE'), isTrue);
      expect(res.contains('AIPD'), isTrue);
      expect(res.contains('CDCT'), isTrue);
      expect(res.contains('FBC'), isTrue);
      expect(res.contains('Official Examination Instructions'), isTrue);
    });

    test('Subject-specific AIPD query highlights AIPD exam date & time', () {
      final res = AcademicSolverService.getExamScheduleResponse(
        userText: 'when is my aipd exam?',
        language: 'ENGLISH',
      );

      expect(res.contains('AI Product Design (AIPD - DI05016021)'), isTrue);
      expect(res.contains('Tuesday, 29-09-2026'), isTrue);
      expect(res.contains('11:30 AM – 12:30 PM'), isTrue);
      expect(res.contains('Semester 5 Mid-Sem Examination Schedule'), isTrue);
    });

    test('Subject-specific FBC query highlights FBC exam date & time', () {
      final res = AcademicSolverService.getExamScheduleResponse(
        userText: 'fbc exam date',
        language: 'ENGLISH',
      );

      expect(res.contains('Foundation of Blockchain (FBC - DI05016051)'), isTrue);
      expect(res.contains('Thursday, 01-10-2026'), isTrue);
      expect(res.contains('11:30 AM – 12:30 PM'), isTrue);
    });

    test('Gujarati exam schedule returns Gujarati table & guidelines', () {
      final res = AcademicSolverService.getExamScheduleResponse(
        userText: 'પરીક્ષા ક્યારે છે?',
        language: 'GUJARATI',
      );

      expect(res.contains('ઇન્ફોર્મેશન ટેકનોલોજી'), isTrue);
      expect(res.contains('સમયપત્રક'), isTrue);
      expect(res.contains('28-09-2026'), isTrue);
      expect(res.contains('સોમવાર'), isTrue);
      expect(res.contains('પરીક્ષા નિયમો'), isTrue);
    });

    test('ChatRepository resolves exam schedule query with timetable dataType and payload', () async {
      final repo = ChatRepository();
      const college = CollegeModel(
        id: '6c6e9b83-cabf-4b13-855b-97d2e1461177',
        name: 'Government Polytechnic, Himmatnagar',
        shortName: 'GPH',
        code: '624',
        city: 'Himmatnagar',
        state: 'Gujarat',
        address: 'Motipura, Himmatnagar',
        rating: 4.5,
        studentCount: 1500,
        admissionsOpen: true,
        tags: ['diploma', 'engineering'],
        faqs: {},
        contactPhone: '02772-229285',
        contactEmail: 'gph-hmt@gujgov.edu.in',
        website: 'https://gph.cteguj.org',
      );

      final msg = await repo.processUserMessageAsync(
        userText: 'whats my exam schedule?',
        college: college,
        isVerified: true,
      );

      expect(msg.dataType, equals(ChatDataType.timetable));
      expect(msg.payload, isNotNull);
      expect(msg.payload!['fileUrl'], isNotNull);
      expect(msg.payload!['title'], contains('Exam Schedule'));
      expect(msg.text.contains('11:30 AM – 12:30 PM'), isTrue);
      expect(msg.text.contains('28-09-2026'), isTrue);
    });
  });
}

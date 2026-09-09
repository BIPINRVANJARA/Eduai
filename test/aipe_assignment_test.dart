import 'package:flutter_test/flutter_test.dart';
import 'package:parent_ai/core/services/academic_solver_service.dart';
import 'package:parent_ai/repositories/chat_repository.dart';
import 'package:parent_ai/models/college_model.dart';
import 'package:parent_ai/models/chat_message_model.dart';

void main() {
  group('AIPE Assignment 2 Resolution Tests', () {
    test('AIPE Assignment 2 Question 1 returns exact GTU LLM definition and solution', () {
      final res = AcademicSolverService.solveAssignmentQuestion(
        userText: 'give me aipe assignment 2 question 1 ans',
        activeSubject: 'Artificial Intelligence and Prompt Engineering (AIPE)',
        activeDocumentTitle: 'AIPE Assignment 2 - Unit 2',
        language: 'ENGLISH',
      );

      expect(res.contains('Question 1: Define LLM (Large Language Model)'), isTrue);
      expect(res.contains('Large Language Model (LLM)'), isTrue);
      expect(res.contains('Transformer neural network architecture'), isTrue);
      expect(res.contains('Byte-Pair Encoding'), isTrue);
      expect(res.contains('Tokenization'), isTrue);
      expect(res.contains('GPT'), isTrue);
      expect(res.contains('LLaMA'), isTrue);
    });

    test('ChatRepository resolves AIPE Assignment 2 Question 1 with correct text and PDF payload', () async {
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
        userText: 'give me aipe assignment 2 question 1 ans',
        college: college,
        isVerified: true,
      );

      expect(msg.text.contains('Question 1: Define LLM (Large Language Model)'), isTrue);
      expect(msg.payload, isNotNull);
      expect(msg.payload!['title'], contains('Assignment 2'));
    });
  });
}

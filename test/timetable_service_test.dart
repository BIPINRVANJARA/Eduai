import 'package:flutter_test/flutter_test.dart';
import 'package:parent_ai/core/services/timetable_service.dart';

void main() {
  group('TimetableService Current Lecture Tests', () {
    test('Tuesday 2:15 PM (14:15) Sem 5 Div A returns AIPE lecture with HIR in Room 733', () {
      // 15-Sep-2026 is a Tuesday
      final tuesdayTime = DateTime(2026, 9, 15, 14, 15);

      final res = TimetableService.getCurrentLectureResponse(
        userText: 'what is my current lecture?',
        currentTime: tuesdayTime,
        studentSemester: 5,
        studentDivision: 'A',
        language: 'ENGLISH',
      );

      expect(res.contains('Current Ongoing Lecture / Lab Session'), isTrue);
      expect(res.contains('AIPE'), isTrue);
      expect(res.contains('Artificial Intelligence with Prompt Engineering'), isTrue);
      expect(res.contains('14:00 – 15:00'), isTrue);
      expect(res.contains('733'), isTrue);
      expect(res.contains('HIR'), isTrue);
      expect(res.contains('Upcoming Next Session'), isTrue);
      expect(res.contains('AIPD'), isTrue);
      expect(res.contains('15:00 – 16:00'), isTrue);
    });

    test('Tuesday 11:00 AM (11:00) Sem 5 Div A returns multi-batch lab session', () {
      final tuesdayTime = DateTime(2026, 9, 15, 11, 0);

      final res = TimetableService.getCurrentLectureResponse(
        userText: 'current class',
        currentTime: tuesdayTime,
        studentSemester: 5,
        studentDivision: 'A',
        language: 'ENGLISH',
      );

      expect(res.contains('Practical Lab Sessions Running (Batch-wise)'), isTrue);
      expect(res.contains('10:30 – 12:30'), isTrue);
      expect(res.contains('Batch A1'), isTrue);
      expect(res.contains('CDCT'), isTrue);
      expect(res.contains('Batch A2'), isTrue);
      expect(res.contains('FBC'), isTrue);
      expect(res.contains('Batch A3'), isTrue);
      expect(res.contains('Upcoming Next Session'), isTrue);
      expect(res.contains('12:30 – 13:30'), isTrue);
    });

    test('Lunch / Recess break at 1:45 PM (13:45) indicates break and shows next lecture at 2:00 PM', () {
      final lunchTime = DateTime(2026, 9, 15, 13, 45);

      final res = TimetableService.getCurrentLectureResponse(
        userText: 'which lecture is going on right now?',
        currentTime: lunchTime,
        studentSemester: 5,
        studentDivision: 'A',
        language: 'ENGLISH',
      );

      expect(res.contains('Currently Recess / Lunch Break'), isTrue);
      expect(res.contains('01:30 PM to 02:00 PM'), isTrue);
      expect(res.contains('Next Lecture Resuming at 02:00 PM'), isTrue);
      expect(res.contains('AIPE'), isTrue);
    });

    test('Short gap break at 4:05 PM (16:05) indicates 10-minute transition gap', () {
      final breakTime = DateTime(2026, 9, 15, 16, 5);

      final res = TimetableService.getCurrentLectureResponse(
        userText: 'current lecture',
        currentTime: breakTime,
        studentSemester: 5,
        studentDivision: 'A',
        language: 'ENGLISH',
      );

      expect(res.contains('10-Minute Transition Gap'), isTrue);
      expect(res.contains('04:00 PM – 04:10 PM'), isTrue);
      expect(res.contains('Next Session Resumes at 04:10 PM'), isTrue);
      expect(res.contains('MP'), isTrue);
    });

    test('Before college hours at 9:15 AM indicates college not started and previews first lecture', () {
      final morningTime = DateTime(2026, 9, 15, 9, 15);

      final res = TimetableService.getCurrentLectureResponse(
        userText: 'what is my current lecture?',
        currentTime: morningTime,
        studentSemester: 5,
        studentDivision: 'A',
        language: 'ENGLISH',
      );

      expect(res.contains('College Hours Have Not Begun Yet'), isTrue);
      expect(res.contains('10:30 AM to 06:10 PM'), isTrue);
      expect(res.contains('First Session of the Day (Starts at 10:30 AM)'), isTrue);
      expect(res.contains('CDCT'), isTrue);
    });

    test('After college hours at 7:00 PM (19:00) indicates college hours concluded', () {
      final eveningTime = DateTime(2026, 9, 15, 19, 0);

      final res = TimetableService.getCurrentLectureResponse(
        userText: 'current lecture',
        currentTime: eveningTime,
        studentSemester: 5,
        studentDivision: 'A',
        language: 'ENGLISH',
      );

      expect(res.contains('College Hours Have Concluded for Today'), isTrue);
      expect(res.contains('10:30 AM to 06:10 PM'), isTrue);
      expect(res.contains('tomorrow timetable'), isTrue);
    });

    test('Weekend Saturday indicates college closed', () {
      // 19-Sep-2026 is Saturday
      final saturdayTime = DateTime(2026, 9, 19, 11, 0);

      final res = TimetableService.getCurrentLectureResponse(
        userText: 'what lecture right now?',
        currentTime: saturdayTime,
        studentSemester: 5,
        studentDivision: 'A',
        language: 'ENGLISH',
      );

      expect(res.contains('Weekend Notice: College is Closed Today'), isTrue);
      expect(res.contains('Saturday'), isTrue);
      expect(res.contains('Monday to Friday'), isTrue);
    });

    test('Gujarati query returns accurate Gujarati timetable response', () {
      final tuesdayTime = DateTime(2026, 9, 15, 14, 15);

      final res = TimetableService.getCurrentLectureResponse(
        userText: 'હમણાં કયો લેક્ચર ચાલુ છે?',
        currentTime: tuesdayTime,
        studentSemester: 5,
        studentDivision: 'A',
        language: 'GUJARATI',
      );

      expect(res.contains('હમણાં ચાલુ લેક્ચર / સેશન'), isTrue);
      expect(res.contains('AIPE'), isTrue);
      expect(res.contains('14:00 થી 15:00'), isTrue);
      expect(res.contains('733'), isTrue);
      expect(res.contains('HIR'), isTrue);
      expect(res.contains('આગામી લેક્ચર'), isTrue);
      expect(res.contains('AIPD'), isTrue);
    });
  });

  group('TimetableService Daily Schedule Tests', () {
    test('Daily schedule for Monday Sem 5 Div A returns full table with all lectures and labs', () {
      final res = TimetableService.getDailyScheduleResponse(
        userText: 'monday timetable for sem 5 div a',
        studentSemester: 5,
        studentDivision: 'A',
        language: 'ENGLISH',
      );

      expect(res.contains('Government Polytechnic, Himatnagar — IT Department Timetable'), isTrue);
      expect(res.contains('**Day:** **Monday**'), isTrue);
      expect(res.contains('Sem 5 (Div A)'), isTrue);
      expect(res.contains('10:30 – 11:30'), isTrue);
      expect(res.contains('AIPE'), isTrue);
      expect(res.contains('CDCT'), isTrue);
      expect(res.contains('AIPD'), isTrue);
      expect(res.contains('Lunch/Recess Break is 01:30 PM – 02:00 PM'), isTrue);
    });

    test('Daily schedule for Sem 1 returns 1st semester timetable', () {
      final res = TimetableService.getDailyScheduleResponse(
        userText: 'sem 1 friday timetable',
        studentSemester: 1,
        language: 'ENGLISH',
      );

      expect(res.contains('Sem 1'), isTrue);
      expect(res.contains('Friday'), isTrue);
      expect(res.contains('Maths-1'), isTrue);
      expect(res.contains('Python'), isTrue);
      expect(res.contains('C.S.'), isTrue);
      expect(res.contains('Chem'), isTrue);
      expect(res.contains('ITS'), isTrue);
    });

    test('Daily schedule for Sunday returns Weekend Notice', () {
      final res = TimetableService.getDailyScheduleResponse(
        userText: 'sunday timetable',
        dayName: 'Sunday',
        language: 'ENGLISH',
      );

      expect(res.contains('College is Closed on Sunday (Weekend Holiday)'), isTrue);
    });
  });
}

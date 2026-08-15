import '../models/student_model.dart';

class StudentRepository {
  static final List<StudentModel> mockStudents = [
    const StudentModel(
      enrollmentNo: '210010116045',
      registeredMobile: '9876543210',
      studentName: 'Aarav Patel',
      parentName: 'Mrs. Patel',
      branch: 'Computer Science & Engineering',
      semester: 6,
      collegeId: 'gec_01',
      overallAttendance: 84.5,
      subjectAttendances: [
        SubjectAttendance(
          subjectCode: '3160704',
          subjectName: 'Artificial Intelligence & Machine Learning',
          totalClasses: 42,
          attendedClasses: 38,
        ),
        SubjectAttendance(
          subjectCode: '3160707',
          subjectName: 'Advanced Java Technologies',
          totalClasses: 40,
          attendedClasses: 32,
        ),
        SubjectAttendance(
          subjectCode: '3160712',
          subjectName: 'Cloud Computing & DevOps',
          totalClasses: 36,
          attendedClasses: 31,
        ),
        SubjectAttendance(
          subjectCode: '3160714',
          subjectName: 'Software Engineering & Agile',
          totalClasses: 38,
          attendedClasses: 30,
        ),
        SubjectAttendance(
          subjectCode: '3160716',
          subjectName: 'Cyber Security Essentials',
          totalClasses: 30,
          attendedClasses: 22,
        ),
      ],
      internalMarks: [
        SubjectMark(
          subjectCode: '3160704',
          subjectName: 'Artificial Intelligence & ML',
          score: 28.5,
          maxScore: 30.0,
          grade: 'A+',
        ),
        SubjectMark(
          subjectCode: '3160707',
          subjectName: 'Advanced Java Technologies',
          score: 24.0,
          maxScore: 30.0,
          grade: 'A',
        ),
        SubjectMark(
          subjectCode: '3160712',
          subjectName: 'Cloud Computing & DevOps',
          score: 26.0,
          maxScore: 30.0,
          grade: 'A+',
        ),
        SubjectMark(
          subjectCode: '3160714',
          subjectName: 'Software Engineering',
          score: 22.5,
          maxScore: 30.0,
          grade: 'B+',
        ),
      ],
      feeTotal: 45000.0,
      feePaid: 45000.0,
      feeDue: 0.0,
      feeDueDate: '15 Jan 2026 (Paid)',
      weeklySchedule: {
        'Monday': [
          TimetableSlot(
            time: '10:30 AM - 11:30 AM',
            subject: 'AI & Machine Learning (Lecture)',
            room: 'Lab 402',
            faculty: 'Prof. K. Mehta',
          ),
          TimetableSlot(
            time: '11:30 AM - 01:30 PM',
            subject: 'Cloud Computing Lab',
            room: 'Server Room B',
            faculty: 'Dr. S. Shah',
          ),
          TimetableSlot(
            time: '02:00 PM - 03:00 PM',
            subject: 'Cyber Security',
            room: 'Auditorium 2',
            faculty: 'Prof. R. Joshi',
          ),
        ],
        'Tuesday': [
          TimetableSlot(
            time: '10:30 AM - 12:30 PM',
            subject: 'Advanced Java Lab',
            room: 'Lab 301',
            faculty: 'Prof. N. Patel',
          ),
          TimetableSlot(
            time: '01:30 PM - 02:30 PM',
            subject: 'Software Engineering',
            room: 'Hall C',
            faculty: 'Dr. V. Trivedi',
          ),
        ],
        'Wednesday': [
          TimetableSlot(
            time: '10:30 AM - 11:30 AM',
            subject: 'AI & Machine Learning',
            room: 'Lab 402',
            faculty: 'Prof. K. Mehta',
          ),
          TimetableSlot(
            time: '11:30 AM - 12:30 PM',
            subject: 'Cloud Computing',
            room: 'Lab 204',
            faculty: 'Dr. S. Shah',
          ),
          TimetableSlot(
            time: '02:00 PM - 04:00 PM',
            subject: 'Major Project Seminar',
            room: 'Seminar Hall 1',
            faculty: 'Prof. Head of Dept',
          ),
        ],
        'Thursday': [
          TimetableSlot(
            time: '10:30 AM - 12:30 PM',
            subject: 'AI & ML Lab Practice',
            room: 'AI Lab',
            faculty: 'Prof. K. Mehta',
          ),
          TimetableSlot(
            time: '01:30 PM - 02:30 PM',
            subject: 'Cyber Security',
            room: 'Hall A',
            faculty: 'Prof. R. Joshi',
          ),
        ],
        'Friday': [
          TimetableSlot(
            time: '10:30 AM - 11:30 AM',
            subject: 'Software Engineering',
            room: 'Hall C',
            faculty: 'Dr. V. Trivedi',
          ),
          TimetableSlot(
            time: '11:30 AM - 01:30 PM',
            subject: 'Placement Preparation Training',
            room: 'Main Auditorium',
            faculty: 'T&P Officer',
          ),
        ],
      },
    ),
    const StudentModel(
      enrollmentNo: '210010116088',
      registeredMobile: '9812345678',
      studentName: 'Ananya Sharma',
      parentName: 'Mr. Sharma',
      branch: 'Information Technology',
      semester: 6,
      collegeId: 'ldrp_02',
      overallAttendance: 72.0,
      subjectAttendances: [
        SubjectAttendance(
          subjectCode: 'IT601',
          subjectName: 'Data Science Fundamentals',
          totalClasses: 40,
          attendedClasses: 32,
        ),
        SubjectAttendance(
          subjectCode: 'IT602',
          subjectName: 'Web Frameworks & React',
          totalClasses: 38,
          attendedClasses: 25,
        ),
        SubjectAttendance(
          subjectCode: 'IT603',
          subjectName: 'Database Security',
          totalClasses: 35,
          attendedClasses: 24,
        ),
      ],
      internalMarks: [
        SubjectMark(
          subjectCode: 'IT601',
          subjectName: 'Data Science Fundamentals',
          score: 26.0,
          maxScore: 30.0,
          grade: 'A',
        ),
        SubjectMark(
          subjectCode: 'IT602',
          subjectName: 'Web Frameworks',
          score: 21.0,
          maxScore: 30.0,
          grade: 'B+',
        ),
      ],
      feeTotal: 52000.0,
      feePaid: 35000.0,
      feeDue: 17000.0,
      feeDueDate: '25 Feb 2026',
      weeklySchedule: {},
    ),
  ];

  StudentModel? verifyAndGetStudent(String enrollmentNo, String mobileNo) {
    final cleanEnrollment = enrollmentNo.trim();
    final cleanMobile = mobileNo.trim();
    try {
      return mockStudents.firstWhere(
        (s) => s.enrollmentNo == cleanEnrollment && s.registeredMobile == cleanMobile,
      );
    } catch (_) {
      // Fallback: If parent enters any enrollment with default length, return Aarav's sample for demo ease
      if (cleanEnrollment.length >= 8) {
        final sample = mockStudents.first;
        return StudentModel(
          enrollmentNo: cleanEnrollment,
          registeredMobile: cleanMobile,
          studentName: 'Aarav Patel',
          parentName: 'Mrs. Patel',
          branch: sample.branch,
          semester: sample.semester,
          collegeId: sample.collegeId,
          overallAttendance: sample.overallAttendance,
          subjectAttendances: sample.subjectAttendances,
          internalMarks: sample.internalMarks,
          feeTotal: sample.feeTotal,
          feePaid: sample.feePaid,
          feeDue: sample.feeDue,
          feeDueDate: sample.feeDueDate,
          weeklySchedule: sample.weeklySchedule,
        );
      }
      return null;
    }
  }
}

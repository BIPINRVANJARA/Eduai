class SubjectAttendance {
  final String subjectCode;
  final String subjectName;
  final int totalClasses;
  final int attendedClasses;

  const SubjectAttendance({
    required this.subjectCode,
    required this.subjectName,
    required this.totalClasses,
    required this.attendedClasses,
  });

  double get percentage =>
      totalClasses == 0 ? 0.0 : (attendedClasses / totalClasses) * 100;
}

class SubjectMark {
  final String subjectCode;
  final String subjectName;
  final double score;
  final double maxScore;
  final String grade;

  const SubjectMark({
    required this.subjectCode,
    required this.subjectName,
    required this.score,
    required this.maxScore,
    required this.grade,
  });
}

class TimetableSlot {
  final String time;
  final String subject;
  final String room;
  final String faculty;

  const TimetableSlot({
    required this.time,
    required this.subject,
    required this.room,
    required this.faculty,
  });
}

class StudentModel {
  final String enrollmentNo;
  final String registeredMobile;
  final String studentName;
  final String parentName;
  final String branch;
  final int semester;
  final String collegeId;
  final double overallAttendance;
  final List<SubjectAttendance> subjectAttendances;
  final List<SubjectMark> internalMarks;
  final double feeTotal;
  final double feePaid;
  final double feeDue;
  final String feeDueDate;
  final Map<String, List<TimetableSlot>> weeklySchedule;

  const StudentModel({
    required this.enrollmentNo,
    required this.registeredMobile,
    required this.studentName,
    required this.parentName,
    required this.branch,
    required this.semester,
    required this.collegeId,
    required this.overallAttendance,
    required this.subjectAttendances,
    required this.internalMarks,
    required this.feeTotal,
    required this.feePaid,
    required this.feeDue,
    required this.feeDueDate,
    required this.weeklySchedule,
  });
}

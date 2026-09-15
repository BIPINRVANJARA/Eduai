// Official IT Department Timetable Service (Term 261-ODD 2026-27)
// Government Polytechnic, Himatnagar - IT Department Semesters 1, 3, 5
import 'package:intl/intl.dart';

class TimetableEntry {
  final String day;
  final int semester;
  final String? division;
  final String? batch;
  final String activityType; // 'LECTURE', 'LAB', 'TUTORIAL'
  final String subject;
  final String? faculty;
  final String? room;
  final String startTime; // '10:30'
  final String endTime;   // '11:30'
  final String? note;

  const TimetableEntry({
    required this.day,
    required this.semester,
    this.division,
    this.batch,
    required this.activityType,
    required this.subject,
    this.faculty,
    this.room,
    required this.startTime,
    required this.endTime,
    this.note,
  });

  int get startMinutes => _toMinutes(startTime);
  int get endMinutes => _toMinutes(endTime);

  static int _toMinutes(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length < 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  bool isOngoing(int currentMins) => currentMins >= startMinutes && currentMins < endMinutes;
  bool isUpcoming(int currentMins) => startMinutes >= currentMins;
}

class TimetableService {
  static const Map<String, String> subjectFullNames = {
    'AIPE': 'Artificial Intelligence with Prompt Engineering (DI05016011)',
    'AIPD': 'AI Product Design (DI05016021)',
    'CDCT': 'Cloud and Data Center Technology (DI05016031)',
    'FBC': 'Foundation of Blockchain (DI05016051)',
    'MP': 'Capstone Major Project Work & Seminar',
    'OOP': 'Object Oriented Programming with C++/Java',
    'Database': 'Database Management Systems (DBMS)',
    'OS': 'Operating Systems',
    'CWS': 'Computer Workshop & Web Technology',
    'DSP': 'Data Structures using Python',
    'DIM': 'Discrete Mathematics',
    'Python': 'Python Programming',
    'PHP': 'Web Technology with PHP',
    'PHP-T': 'Web Technology with PHP (Tutorial)',
    'ITS': 'Information Technology Systems & Fundamentals',
    'IoT': 'Internet of Things',
    'IoT-T': 'Internet of Things (Tutorial)',
    'Maths-1': 'Basic Mathematics - I',
    'Maths-1 T': 'Basic Mathematics - I (Tutorial)',
    'Chem': 'Engineering Chemistry',
    'Eng-Chem': 'Engineering Chemistry',
    'C.S.': 'Communication Skills in English',
    'S&Y': 'Sports and Yoga / Physical Education',
  };

  static String getSubjectFullName(String code) {
    return subjectFullNames[code] ?? code;
  }

  static const List<TimetableEntry> entries = [
    TimetableEntry(day: 'Monday', semester: 1, division: null, batch: 'A1', activityType: 'LAB', subject: 'Python', faculty: 'BPM', room: '737B', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Monday', semester: 1, division: null, batch: 'A2', activityType: 'LAB', subject: 'ITS', faculty: 'UJP', room: '737A', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Monday', semester: 1, division: null, batch: 'A3', activityType: 'LAB', subject: 'PHP', faculty: 'VPP', room: '738B', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Monday', semester: 1, division: null, batch: null, activityType: 'LECTURE', subject: 'Python', faculty: 'BPM', room: null, startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Monday', semester: 1, division: null, batch: null, activityType: 'LECTURE', subject: 'ITS', faculty: 'UJP', room: null, startTime: '14:00', endTime: '15:00', note: null),
    TimetableEntry(day: 'Monday', semester: 1, division: null, batch: 'A1', activityType: 'LAB', subject: 'ITS', faculty: 'UJP', room: '736', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Monday', semester: 1, division: null, batch: 'A2', activityType: 'LAB', subject: 'S&Y', faculty: 'RAM', room: 'A.B', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Monday', semester: 1, division: null, batch: 'A3', activityType: 'LAB', subject: 'Python', faculty: 'BPM', room: '737B', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Monday', semester: 3, division: 'A', batch: null, activityType: 'LECTURE', subject: 'DSP', faculty: 'CBP', room: null, startTime: '10:30', endTime: '11:30', note: null),
    TimetableEntry(day: 'Monday', semester: 3, division: 'A', batch: null, activityType: 'LECTURE', subject: 'CWS', faculty: 'VAG', room: null, startTime: '11:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Monday', semester: 3, division: 'A', batch: null, activityType: 'LECTURE', subject: 'OS', faculty: 'DKP', room: null, startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Monday', semester: 3, division: 'A', batch: null, activityType: 'LECTURE', subject: 'Database', faculty: 'VPP', room: null, startTime: '14:00', endTime: '15:00', note: null),
    TimetableEntry(day: 'Monday', semester: 3, division: 'A', batch: 'A1', activityType: 'LAB', subject: 'OOP', faculty: 'NKK', room: '306A', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Monday', semester: 3, division: 'A', batch: 'A2', activityType: 'LAB', subject: 'CWS', faculty: 'VAG', room: '306B', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Monday', semester: 3, division: 'A', batch: 'A3', activityType: 'LAB', subject: 'Database', faculty: 'VPP', room: '738A', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Monday', semester: 3, division: 'B', batch: 'B1', activityType: 'LAB', subject: 'OOP', faculty: 'RAM', room: '306A', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Monday', semester: 3, division: 'B', batch: 'B2', activityType: 'LAB', subject: 'DIM', faculty: 'BSP', room: '738A', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Monday', semester: 3, division: 'B', batch: 'B3', activityType: 'LAB', subject: 'Database', faculty: 'DKP', room: '303A', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Monday', semester: 3, division: 'B', batch: 'B4', activityType: 'LAB', subject: 'CWS', faculty: 'NKK', room: '306B', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Monday', semester: 3, division: 'B', batch: null, activityType: 'LECTURE', subject: 'DIM', faculty: 'BSP', room: null, startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Monday', semester: 3, division: 'B', batch: null, activityType: 'LECTURE', subject: 'CWS', faculty: 'VAG', room: null, startTime: '14:00', endTime: '15:00', note: null),
    TimetableEntry(day: 'Monday', semester: 3, division: 'B', batch: 'B1', activityType: 'LAB', subject: 'DIM', faculty: 'BSP', room: '305', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Monday', semester: 3, division: 'B', batch: 'B2', activityType: 'LAB', subject: 'DSP', faculty: 'CBP', room: '303A', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Monday', semester: 3, division: 'B', batch: 'B3', activityType: 'LAB', subject: 'OS', faculty: 'PDJ', room: '303B', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Monday', semester: 5, division: 'A', batch: null, activityType: 'LECTURE', subject: 'AIPE', faculty: 'HIR', room: '732', startTime: '10:30', endTime: '11:30', note: null),
    TimetableEntry(day: 'Monday', semester: 5, division: 'A', batch: null, activityType: 'LECTURE', subject: 'FBC', faculty: 'CDS', room: '732', startTime: '11:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Monday', semester: 5, division: 'A', batch: 'A1', activityType: 'LAB', subject: 'AIPE', faculty: 'HIR', room: '737B', startTime: '12:30', endTime: '15:00', note: null),
    TimetableEntry(day: 'Monday', semester: 5, division: 'A', batch: 'A2', activityType: 'LAB', subject: 'CDCT', faculty: 'CGP', room: '737A', startTime: '12:30', endTime: '15:00', note: null),
    TimetableEntry(day: 'Monday', semester: 5, division: 'A', batch: 'A3', activityType: 'LAB', subject: 'AIPD', faculty: 'PVP', room: '738B', startTime: '12:30', endTime: '15:00', note: null),
    TimetableEntry(day: 'Monday', semester: 5, division: 'B', batch: null, activityType: 'LECTURE', subject: 'AIPD', faculty: 'HNR', room: '733', startTime: '10:30', endTime: '11:30', note: null),
    TimetableEntry(day: 'Monday', semester: 5, division: 'B', batch: null, activityType: 'LECTURE', subject: 'CDCT', faculty: 'CGP', room: '733', startTime: '11:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Monday', semester: 5, division: 'B', batch: 'B1', activityType: 'LAB', subject: 'FBC', faculty: 'AJB', room: '306A', startTime: '12:30', endTime: '15:00', note: null),
    TimetableEntry(day: 'Monday', semester: 5, division: 'B', batch: 'B2', activityType: 'LAB', subject: 'CDCT', faculty: 'PDJ', room: '303B', startTime: '12:30', endTime: '15:00', note: null),
    TimetableEntry(day: 'Monday', semester: 5, division: 'B', batch: 'B3', activityType: 'LAB', subject: 'AIPE', faculty: 'CDS', room: '738A', startTime: '12:30', endTime: '15:00', note: null),
    TimetableEntry(day: 'Monday', semester: 5, division: 'B', batch: 'B4', activityType: 'LAB', subject: 'AIPD', faculty: 'HNR', room: '306B', startTime: '12:30', endTime: '15:00', note: null),
    TimetableEntry(day: 'Monday', semester: 5, division: 'B', batch: 'B1', activityType: 'LAB', subject: 'CDCT', faculty: 'CGP', room: '738B', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Monday', semester: 5, division: 'B', batch: 'B2', activityType: 'LAB', subject: 'MP', faculty: 'DKP', room: '301', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Monday', semester: 5, division: 'B', batch: 'B3', activityType: 'LAB', subject: 'MP', faculty: 'PNP', room: '302', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Tuesday', semester: 1, division: null, batch: null, activityType: 'LECTURE', subject: 'Eng-Chem', faculty: 'VDM', room: null, startTime: '10:30', endTime: '11:30', note: null),
    TimetableEntry(day: 'Tuesday', semester: 1, division: null, batch: 'A1', activityType: 'LAB', subject: 'Eng-Chem', faculty: 'BRP', room: '709', startTime: '11:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Tuesday', semester: 1, division: null, batch: 'A2', activityType: 'LAB', subject: 'Eng-Chem', faculty: 'VDM', room: '709', startTime: '11:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Tuesday', semester: 1, division: null, batch: 'A3', activityType: 'LAB', subject: 'S&Y', faculty: 'RAM', room: 'A.B', startTime: '11:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Tuesday', semester: 1, division: null, batch: 'TA1', activityType: 'TUTORIAL', subject: 'Maths-1 T', faculty: 'JJP', room: null, startTime: '14:00', endTime: '15:00', note: null),
    TimetableEntry(day: 'Tuesday', semester: 1, division: null, batch: 'TA2', activityType: 'TUTORIAL', subject: 'Maths-1 T', faculty: 'RGC', room: null, startTime: '14:00', endTime: '15:00', note: null),
    TimetableEntry(day: 'Tuesday', semester: 1, division: null, batch: 'TA1', activityType: 'TUTORIAL', subject: 'PHP-T', faculty: 'BPM', room: '737A', startTime: '15:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Tuesday', semester: 1, division: null, batch: 'TA2', activityType: 'TUTORIAL', subject: 'PHP-T', faculty: 'VPP', room: '302', startTime: '15:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Tuesday', semester: 1, division: null, batch: 'A3', activityType: 'LAB', subject: 'Eng-Chem', faculty: 'VDM', room: '709', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Tuesday', semester: 3, division: 'A', batch: null, activityType: 'LECTURE', subject: 'OOP', faculty: 'NKK', room: null, startTime: '10:30', endTime: '11:30', note: null),
    TimetableEntry(day: 'Tuesday', semester: 3, division: 'A', batch: null, activityType: 'LECTURE', subject: 'DIM', faculty: 'BSP', room: null, startTime: '11:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Tuesday', semester: 3, division: 'A', batch: null, activityType: 'LECTURE', subject: 'OS', faculty: 'DKP', room: null, startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Tuesday', semester: 3, division: 'A', batch: null, activityType: 'LECTURE', subject: 'Database', faculty: 'VPP', room: null, startTime: '14:00', endTime: '15:00', note: null),
    TimetableEntry(day: 'Tuesday', semester: 3, division: 'A', batch: 'A1', activityType: 'LAB', subject: 'CWS', faculty: 'VAG', room: '738B', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Tuesday', semester: 3, division: 'A', batch: 'A2', activityType: 'LAB', subject: 'DIM', faculty: 'BSP', room: '738A', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Tuesday', semester: 3, division: 'A', batch: 'A3', activityType: 'LAB', subject: 'OOP', faculty: 'NKK', room: '306A', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Tuesday', semester: 3, division: 'B', batch: null, activityType: 'LECTURE', subject: 'OOP', faculty: 'RAM', room: null, startTime: '10:30', endTime: '11:30', note: null),
    TimetableEntry(day: 'Tuesday', semester: 3, division: 'B', batch: null, activityType: 'LECTURE', subject: 'CWS', faculty: 'VAG', room: null, startTime: '11:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Tuesday', semester: 3, division: 'B', batch: null, activityType: 'LECTURE', subject: 'DSP', faculty: 'CBP', room: null, startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Tuesday', semester: 3, division: 'B', batch: 'B1', activityType: 'LAB', subject: 'Database', faculty: 'DKP', room: '303A', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Tuesday', semester: 3, division: 'B', batch: 'B2', activityType: 'LAB', subject: 'OOP', faculty: 'RAM', room: '306B', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Tuesday', semester: 3, division: 'B', batch: 'B3', activityType: 'LAB', subject: 'DSP', faculty: 'CBP', room: '737B', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Tuesday', semester: 3, division: 'B', batch: 'B4', activityType: 'LAB', subject: 'OS', faculty: 'PDJ', room: '303B', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Tuesday', semester: 3, division: 'B', batch: 'B4', activityType: 'LAB', subject: 'Database', faculty: 'DKP', room: '303A', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Tuesday', semester: 5, division: 'A', batch: 'A1', activityType: 'LAB', subject: 'CDCT', faculty: 'CGP', room: '306A', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Tuesday', semester: 5, division: 'A', batch: 'A2', activityType: 'LAB', subject: 'FBC', faculty: 'AJB', room: '306B', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Tuesday', semester: 5, division: 'A', batch: 'A3', activityType: 'LAB', subject: 'CDCT', faculty: 'PDJ', room: '303B', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Tuesday', semester: 5, division: 'A', batch: null, activityType: 'LECTURE', subject: 'CDCT', faculty: 'PDJ', room: '733', startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Tuesday', semester: 5, division: 'A', batch: null, activityType: 'LECTURE', subject: 'AIPE', faculty: 'HIR', room: '733', startTime: '14:00', endTime: '15:00', note: null),
    TimetableEntry(day: 'Tuesday', semester: 5, division: 'A', batch: null, activityType: 'LECTURE', subject: 'AIPD', faculty: 'PVP', room: '733', startTime: '15:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Tuesday', semester: 5, division: 'A', batch: 'A2', activityType: 'LAB', subject: 'MP', faculty: 'CDS', room: '305', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Tuesday', semester: 5, division: 'A', batch: 'A3', activityType: 'LAB', subject: 'MP', faculty: 'HIR', room: '736', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Tuesday', semester: 5, division: 'B', batch: 'B1', activityType: 'LAB', subject: 'IoT', faculty: 'JJP', room: '737A', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Tuesday', semester: 5, division: 'B', batch: 'B2', activityType: 'LAB', subject: 'MP', faculty: 'DKP', room: '302', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Tuesday', semester: 5, division: 'B', batch: 'B3', activityType: 'LAB', subject: 'AIPD', faculty: 'HNR', room: '303A', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Tuesday', semester: 5, division: 'B', batch: 'B4', activityType: 'LAB', subject: 'MP', faculty: 'BPM', room: '737B', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Tuesday', semester: 5, division: 'B', batch: null, activityType: 'LECTURE', subject: 'AIPE', faculty: 'CDS', room: '723', startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Tuesday', semester: 5, division: 'B', batch: null, activityType: 'LECTURE', subject: 'FBC', faculty: 'AJB', room: '723', startTime: '14:00', endTime: '15:00', note: null),
    TimetableEntry(day: 'Tuesday', semester: 5, division: 'B', batch: null, activityType: 'LECTURE', subject: 'AIPD', faculty: 'HNR', room: '733', startTime: '15:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Tuesday', semester: 5, division: 'B', batch: 'B1', activityType: 'LAB', subject: 'MP', faculty: 'VPP', room: '301', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Tuesday', semester: 5, division: 'B', batch: 'B3', activityType: 'LAB', subject: 'FBC', faculty: 'AJB', room: '306B', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Tuesday', semester: 5, division: 'B', batch: 'B4', activityType: 'LAB', subject: 'IoT', faculty: 'JJP', room: '737A', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Wednesday', semester: 1, division: null, batch: 'A1', activityType: 'LAB', subject: 'PHP', faculty: 'VPP', room: '738B', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Wednesday', semester: 1, division: null, batch: 'A2', activityType: 'LAB', subject: 'PHP', faculty: 'BPM', room: '737B', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Wednesday', semester: 1, division: null, batch: 'A3', activityType: 'LAB', subject: 'ITS', faculty: 'UJP', room: '736', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Wednesday', semester: 1, division: null, batch: null, activityType: 'LECTURE', subject: 'Maths-1', faculty: 'JJP', room: null, startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Wednesday', semester: 1, division: null, batch: null, activityType: 'LECTURE', subject: 'Eng-Chem', faculty: 'VDM', room: null, startTime: '14:00', endTime: '15:00', note: null),
    TimetableEntry(day: 'Wednesday', semester: 1, division: null, batch: 'A1', activityType: 'LAB', subject: 'S&Y', faculty: 'RAM', room: 'A.B', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Wednesday', semester: 1, division: null, batch: 'A3', activityType: 'LAB', subject: 'PHP', faculty: 'BPM', room: '737A', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Wednesday', semester: 3, division: 'A', batch: null, activityType: 'LECTURE', subject: 'DSP', faculty: 'CBP', room: null, startTime: '10:30', endTime: '11:30', note: null),
    TimetableEntry(day: 'Wednesday', semester: 3, division: 'A', batch: null, activityType: 'LECTURE', subject: 'OOP', faculty: 'NKK', room: null, startTime: '11:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Wednesday', semester: 3, division: 'A', batch: null, activityType: 'LECTURE', subject: 'CWS', faculty: 'VAG', room: null, startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Wednesday', semester: 3, division: 'A', batch: 'A2', activityType: 'LAB', subject: 'Database', faculty: 'VPP', room: '737B', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Wednesday', semester: 3, division: 'A', batch: 'A3', activityType: 'LAB', subject: 'CWS', faculty: 'VAG', room: '738A', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Wednesday', semester: 3, division: 'B', batch: null, activityType: 'LECTURE', subject: 'DIM', faculty: 'BSP', room: null, startTime: '10:30', endTime: '11:30', note: null),
    TimetableEntry(day: 'Wednesday', semester: 3, division: 'B', batch: null, activityType: 'LECTURE', subject: 'Database', faculty: 'DKP', room: null, startTime: '11:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Wednesday', semester: 3, division: 'B', batch: null, activityType: 'LECTURE', subject: 'OS', faculty: 'PDJ', room: null, startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Wednesday', semester: 3, division: 'B', batch: null, activityType: 'LECTURE', subject: 'OOP', faculty: 'RAM', room: null, startTime: '14:00', endTime: '15:00', note: null),
    TimetableEntry(day: 'Wednesday', semester: 3, division: 'B', batch: 'B1', activityType: 'LAB', subject: 'CWS', faculty: 'NKK', room: '306B', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Wednesday', semester: 3, division: 'B', batch: 'B2', activityType: 'LAB', subject: 'Database', faculty: 'DKP', room: '303A', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Wednesday', semester: 3, division: 'B', batch: 'B3', activityType: 'LAB', subject: 'DIM', faculty: 'BSP', room: '301', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Wednesday', semester: 3, division: 'B', batch: 'B4', activityType: 'LAB', subject: 'DSP', faculty: 'CBP', room: '303B', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Wednesday', semester: 5, division: 'A', batch: null, activityType: 'LECTURE', subject: 'AIPD', faculty: 'PVP', room: '733', startTime: '10:30', endTime: '11:30', note: null),
    TimetableEntry(day: 'Wednesday', semester: 5, division: 'A', batch: null, activityType: 'LECTURE', subject: 'AIPE', faculty: 'HIR', room: '733', startTime: '11:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Wednesday', semester: 5, division: 'A', batch: null, activityType: 'LECTURE', subject: 'FBC', faculty: 'CDS', room: '733', startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Wednesday', semester: 5, division: 'A', batch: 'A1', activityType: 'LAB', subject: 'FBC', faculty: 'AJB', room: '306A', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Wednesday', semester: 5, division: 'A', batch: 'A2', activityType: 'LAB', subject: 'AIPD', faculty: 'PVP', room: '736', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Wednesday', semester: 5, division: 'A', batch: 'A3', activityType: 'LAB', subject: 'AIPE', faculty: 'HIR', room: '738B', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Wednesday', semester: 5, division: 'A', batch: 'A1', activityType: 'LAB', subject: 'MP', faculty: 'HIR', room: '736', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Wednesday', semester: 5, division: 'A', batch: 'A2', activityType: 'LAB', subject: 'IoT', faculty: 'HNR', room: '305', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Wednesday', semester: 5, division: 'A', batch: 'A3', activityType: 'LAB', subject: 'MP', faculty: 'PDJ', room: '302', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Wednesday', semester: 5, division: 'B', batch: 'B2', activityType: 'LAB', subject: 'AIPE', faculty: 'CDS', room: '737A', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Wednesday', semester: 5, division: 'B', batch: 'B3', activityType: 'LAB', subject: 'CDCT', faculty: 'CGP', room: '303A', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Wednesday', semester: 5, division: 'B', batch: 'B4', activityType: 'LAB', subject: 'FBC', faculty: 'AJB', room: '306A', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Wednesday', semester: 5, division: 'B', batch: null, activityType: 'LECTURE', subject: 'AIPD', faculty: 'HNR', room: '723', startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Wednesday', semester: 5, division: 'B', batch: null, activityType: 'LECTURE', subject: 'AIPE', faculty: 'CDS', room: '723', startTime: '14:00', endTime: '15:00', note: null),
    TimetableEntry(day: 'Wednesday', semester: 5, division: 'B', batch: 'TB1', activityType: 'TUTORIAL', subject: 'IoT-T', faculty: 'JJP', room: '722', startTime: '15:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Wednesday', semester: 5, division: 'B', batch: 'TB2', activityType: 'TUTORIAL', subject: 'IoT-T', faculty: 'HNR', room: '723', startTime: '15:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Wednesday', semester: 5, division: 'B', batch: 'B2', activityType: 'LAB', subject: 'IoT', faculty: 'JJP', room: '737B', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Wednesday', semester: 5, division: 'B', batch: 'B3', activityType: 'LAB', subject: 'MP', faculty: 'AJB', room: '306A', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Wednesday', semester: 5, division: 'B', batch: 'B4', activityType: 'LAB', subject: 'MP', faculty: 'PVP', room: '738A', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Thursday', semester: 1, division: null, batch: null, activityType: 'LECTURE', subject: 'C.S.', faculty: 'NPP', room: null, startTime: '10:30', endTime: '11:30', note: null),
    TimetableEntry(day: 'Thursday', semester: 1, division: null, batch: null, activityType: 'LECTURE', subject: 'Python', faculty: 'BPM', room: null, startTime: '11:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Thursday', semester: 1, division: null, batch: null, activityType: 'LECTURE', subject: 'Maths-1', faculty: 'JJP', room: null, startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Thursday', semester: 1, division: null, batch: 'A1', activityType: 'LAB', subject: 'C.S.', faculty: 'RSJ', room: '709', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Thursday', semester: 1, division: null, batch: 'A2', activityType: 'LAB', subject: 'C.S.', faculty: 'NPP', room: '709', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Thursday', semester: 1, division: null, batch: 'A3', activityType: 'LAB', subject: 'C.S.', faculty: 'X', room: '709', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Thursday', semester: 1, division: null, batch: 'A1', activityType: 'LAB', subject: 'PHP', faculty: 'VPP', room: '306B', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Thursday', semester: 1, division: null, batch: 'A2', activityType: 'LAB', subject: 'PHP', faculty: 'BPM', room: '737A', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Thursday', semester: 3, division: 'A', batch: 'A1', activityType: 'LAB', subject: 'Database', faculty: 'VPP', room: '737B', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Thursday', semester: 3, division: 'A', batch: 'A2', activityType: 'LAB', subject: 'OOP', faculty: 'NKK', room: '306B', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Thursday', semester: 3, division: 'A', batch: 'A3', activityType: 'LAB', subject: 'DSP', faculty: 'CBP', room: '303B', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Thursday', semester: 3, division: 'A', batch: null, activityType: 'LECTURE', subject: 'OOP', faculty: 'NKK', room: null, startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Thursday', semester: 3, division: 'A', batch: null, activityType: 'LECTURE', subject: 'DIM', faculty: 'BSP', room: null, startTime: '14:00', endTime: '15:00', note: null),
    TimetableEntry(day: 'Thursday', semester: 3, division: 'A', batch: 'A1', activityType: 'LAB', subject: 'OS', faculty: 'PVP', room: '738A', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Thursday', semester: 3, division: 'A', batch: 'A2', activityType: 'LAB', subject: 'DSP', faculty: 'CBP', room: '303A', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Thursday', semester: 3, division: 'B', batch: null, activityType: 'LECTURE', subject: 'DSP', faculty: 'RAM', room: null, startTime: '10:30', endTime: '11:30', note: null),
    TimetableEntry(day: 'Thursday', semester: 3, division: 'B', batch: null, activityType: 'LECTURE', subject: 'OS', faculty: 'PDJ', room: null, startTime: '11:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Thursday', semester: 3, division: 'B', batch: null, activityType: 'LECTURE', subject: 'Database', faculty: 'DKP', room: null, startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Thursday', semester: 3, division: 'B', batch: null, activityType: 'LECTURE', subject: 'CWS', faculty: 'VAG', room: null, startTime: '14:00', endTime: '15:00', note: null),
    TimetableEntry(day: 'Thursday', semester: 3, division: 'B', batch: 'B1', activityType: 'LAB', subject: 'OS', faculty: 'PDJ', room: '303A', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Thursday', semester: 3, division: 'B', batch: 'B2', activityType: 'LAB', subject: 'CWS', faculty: 'NKK', room: '303B', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Thursday', semester: 3, division: 'B', batch: 'B3', activityType: 'LAB', subject: 'OOP', faculty: 'RAM', room: '305', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Thursday', semester: 3, division: 'B', batch: 'B4', activityType: 'LAB', subject: 'DIM', faculty: 'BSP', room: '738B', startTime: '15:00', endTime: '17:10', note: null),
    TimetableEntry(day: 'Thursday', semester: 5, division: 'A', batch: null, activityType: 'LECTURE', subject: 'FBC', faculty: 'CDS', room: '733', startTime: '10:30', endTime: '11:30', note: null),
    TimetableEntry(day: 'Thursday', semester: 5, division: 'A', batch: null, activityType: 'LECTURE', subject: 'AIPD', faculty: 'PVP', room: '733', startTime: '11:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Thursday', semester: 5, division: 'A', batch: null, activityType: 'LECTURE', subject: 'CDCT', faculty: 'CGP', room: '733', startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Thursday', semester: 5, division: 'A', batch: 'TA1', activityType: 'TUTORIAL', subject: 'IoT-T', faculty: 'JJP', room: '733', startTime: '14:00', endTime: '15:00', note: null),
    TimetableEntry(day: 'Thursday', semester: 5, division: 'A', batch: 'TA2', activityType: 'TUTORIAL', subject: 'IoT-T', faculty: 'HNR', room: '723', startTime: '14:00', endTime: '15:00', note: null),
    TimetableEntry(day: 'Thursday', semester: 5, division: 'A', batch: 'TA1', activityType: 'TUTORIAL', subject: 'IoT-T', faculty: 'JJP', room: '733', startTime: '15:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Thursday', semester: 5, division: 'A', batch: 'TA2', activityType: 'TUTORIAL', subject: 'IoT-T', faculty: 'HNR', room: '723', startTime: '15:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Thursday', semester: 5, division: 'A', batch: 'A1', activityType: 'LAB', subject: 'MP', faculty: 'HIR', room: '736', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Thursday', semester: 5, division: 'B', batch: null, activityType: 'LECTURE', subject: 'CDCT', faculty: 'CGP', room: '723', startTime: '10:30', endTime: '11:30', note: null),
    TimetableEntry(day: 'Thursday', semester: 5, division: 'B', batch: null, activityType: 'LECTURE', subject: 'FBC', faculty: 'AJB', room: '723', startTime: '11:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Thursday', semester: 5, division: 'B', batch: 'TB1', activityType: 'TUTORIAL', subject: 'IoT-T', faculty: 'JJP', room: '737A', startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Thursday', semester: 5, division: 'B', batch: 'TB2', activityType: 'TUTORIAL', subject: 'IoT-T', faculty: 'HNR', room: '737B', startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Thursday', semester: 5, division: 'B', batch: 'B1', activityType: 'LAB', subject: 'MP', faculty: 'PNP', room: '301', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Thursday', semester: 5, division: 'B', batch: 'B2', activityType: 'LAB', subject: 'FBC', faculty: 'AJB', room: '306A', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Thursday', semester: 5, division: 'B', batch: 'B4', activityType: 'LAB', subject: 'CDCT', faculty: 'CGP', room: '736', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Thursday', semester: 5, division: 'B', batch: 'B1', activityType: 'LAB', subject: 'MP', faculty: 'VAG', room: '301', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Thursday', semester: 5, division: 'B', batch: 'B4', activityType: 'LAB', subject: 'AIPE', faculty: 'CDS', room: '737B', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Friday', semester: 1, division: null, batch: null, activityType: 'LECTURE', subject: 'Maths-1', faculty: 'JJP', room: null, startTime: '10:30', endTime: '11:30', note: null),
    TimetableEntry(day: 'Friday', semester: 1, division: null, batch: null, activityType: 'LECTURE', subject: 'Python', faculty: 'BPM', room: null, startTime: '11:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Friday', semester: 1, division: null, batch: null, activityType: 'LECTURE', subject: 'C.S.', faculty: 'RSJ', room: null, startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Friday', semester: 1, division: null, batch: null, activityType: 'LECTURE', subject: 'Chem', faculty: 'BRP', room: null, startTime: '14:00', endTime: '15:00', note: null),
    TimetableEntry(day: 'Friday', semester: 1, division: null, batch: null, activityType: 'LECTURE', subject: 'ITS', faculty: 'JJP', room: null, startTime: '15:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Friday', semester: 1, division: null, batch: 'A2', activityType: 'LAB', subject: 'Python', faculty: 'BPM', room: '737A', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Friday', semester: 3, division: 'A', batch: null, activityType: 'LECTURE', subject: 'Database', faculty: 'VPP', room: null, startTime: '10:30', endTime: '11:30', note: null),
    TimetableEntry(day: 'Friday', semester: 3, division: 'A', batch: null, activityType: 'LECTURE', subject: 'CWS', faculty: 'VAG', room: null, startTime: '11:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Friday', semester: 3, division: 'A', batch: null, activityType: 'LECTURE', subject: 'DSP', faculty: 'NKK', room: null, startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Friday', semester: 3, division: 'A', batch: 'A1', activityType: 'LAB', subject: 'DSP', faculty: 'CBP', room: '303A', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Friday', semester: 3, division: 'A', batch: 'A2', activityType: 'LAB', subject: 'OS', faculty: 'PVP', room: '738B', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Friday', semester: 3, division: 'A', batch: 'A3', activityType: 'LAB', subject: 'DIM', faculty: 'BSP', room: '738A', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Friday', semester: 3, division: 'A', batch: 'A1', activityType: 'LAB', subject: 'DIM', faculty: 'BSP', room: '738B', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Friday', semester: 3, division: 'A', batch: 'A3', activityType: 'LAB', subject: 'OS', faculty: 'PVP', room: '738A', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Friday', semester: 3, division: 'B', batch: 'B1', activityType: 'LAB', subject: 'DSP', faculty: 'CBP', room: '303A', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Friday', semester: 3, division: 'B', batch: 'B2', activityType: 'LAB', subject: 'OS', faculty: 'PDJ', room: '303B', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Friday', semester: 3, division: 'B', batch: 'B3', activityType: 'LAB', subject: 'CWS', faculty: 'NKK', room: '306B', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Friday', semester: 3, division: 'B', batch: 'B4', activityType: 'LAB', subject: 'OOP', faculty: 'RAM', room: '306A', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Friday', semester: 3, division: 'B', batch: null, activityType: 'LECTURE', subject: 'DSP', faculty: 'CBP', room: null, startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Friday', semester: 3, division: 'B', batch: null, activityType: 'LECTURE', subject: 'Database', faculty: 'DKP', room: null, startTime: '14:00', endTime: '15:00', note: null),
    TimetableEntry(day: 'Friday', semester: 3, division: 'B', batch: null, activityType: 'LECTURE', subject: 'OOP', faculty: 'RAM', room: null, startTime: '15:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Friday', semester: 5, division: 'A', batch: 'A1', activityType: 'LAB', subject: 'AIPD', faculty: 'PVP', room: '738B', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Friday', semester: 5, division: 'A', batch: 'A2', activityType: 'LAB', subject: 'AIPE', faculty: 'HIR', room: '737A', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Friday', semester: 5, division: 'A', batch: 'A3', activityType: 'LAB', subject: 'IoT', faculty: 'HNR', room: '305', startTime: '10:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Friday', semester: 5, division: 'A', batch: null, activityType: 'LECTURE', subject: 'CDCT', faculty: 'CGP', room: '723', startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Friday', semester: 5, division: 'A', batch: 'A1', activityType: 'LAB', subject: 'MP', faculty: 'HIR', room: '736', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Friday', semester: 5, division: 'A', batch: 'A2', activityType: 'LAB', subject: 'MP', faculty: 'CGP', room: '302', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Friday', semester: 5, division: 'A', batch: 'A3', activityType: 'LAB', subject: 'FBC', faculty: 'AJB', room: '306A', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Friday', semester: 5, division: 'A', batch: 'A1', activityType: 'LAB', subject: 'IoT', faculty: 'HNR', room: '302', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Friday', semester: 5, division: 'A', batch: 'A2', activityType: 'LAB', subject: 'MP', faculty: 'CDS', room: '305', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Friday', semester: 5, division: 'A', batch: 'A3', activityType: 'LAB', subject: 'MP', faculty: 'PDJ', room: '737B', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Friday', semester: 5, division: 'B', batch: null, activityType: 'LECTURE', subject: 'AIPE', faculty: 'CDS', room: '733', startTime: '10:30', endTime: '11:30', note: null),
    TimetableEntry(day: 'Friday', semester: 5, division: 'B', batch: null, activityType: 'LECTURE', subject: 'FBC', faculty: 'AJB', room: '733', startTime: '11:30', endTime: '12:30', note: null),
    TimetableEntry(day: 'Friday', semester: 5, division: 'B', batch: null, activityType: 'LECTURE', subject: 'CDCT', faculty: 'PDJ', room: '733', startTime: '12:30', endTime: '13:30', note: null),
    TimetableEntry(day: 'Friday', semester: 5, division: 'B', batch: 'B1', activityType: 'LAB', subject: 'AIPE', faculty: 'CDS', room: '737A', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Friday', semester: 5, division: 'B', batch: 'B2', activityType: 'LAB', subject: 'AIPD', faculty: 'HNR', room: '737B', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Friday', semester: 5, division: 'B', batch: 'B3', activityType: 'LAB', subject: 'MP', faculty: 'PNP', room: '305', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Friday', semester: 5, division: 'B', batch: 'B4', activityType: 'LAB', subject: 'MP', faculty: 'VAG', room: '306B', startTime: '14:00', endTime: '16:00', note: null),
    TimetableEntry(day: 'Friday', semester: 5, division: 'B', batch: 'B2', activityType: 'LAB', subject: 'MP', faculty: 'DKP', room: '303B', startTime: '16:10', endTime: '18:10', note: null),
    TimetableEntry(day: 'Friday', semester: 5, division: 'B', batch: 'B3', activityType: 'LAB', subject: 'IoT', faculty: 'JJP', room: '736', startTime: '16:10', endTime: '18:10', note: null),
  ];

  /// Resolves current running lecture/lab and upcoming activity
  static String getCurrentLectureResponse({
    required String userText,
    DateTime? currentTime,
    int? studentSemester,
    String? studentDivision,
    String? studentBatch,
    String? language,
  }) {
    final bool isGujarati = language == 'GUJARATI' || RegExp(r'[\u0A80-\u0AFF]').hasMatch(userText);
    final now = currentTime ?? DateTime.now();
    final lower = userText.toLowerCase();

    // 1. Parse target semester (default to studentSemester, or 5 if unassigned)
    int targetSem = studentSemester ?? 5;
    if (lower.contains('sem 1') || lower.contains('sem-1') || lower.contains('semester 1') || lower.contains('1st sem') || lower.contains('sem1')) {
      targetSem = 1;
    } else if (lower.contains('sem 3') || lower.contains('sem-3') || lower.contains('semester 3') || lower.contains('3rd sem') || lower.contains('sem3')) {
      targetSem = 3;
    } else if (lower.contains('sem 5') || lower.contains('sem-5') || lower.contains('semester 5') || lower.contains('5th sem') || lower.contains('sem5')) {
      targetSem = 5;
    }

    // 2. Parse target division (A or B)
    String? targetDiv = studentDivision;
    if (lower.contains('div a') || lower.contains('division a') || lower.contains('section a')) {
      targetDiv = 'A';
    } else if (lower.contains('div b') || lower.contains('division b') || lower.contains('section b')) {
      targetDiv = 'B';
    }
    // Default division A for sem 3 and 5 if null
    if (targetSem > 1 && targetDiv == null) {
      targetDiv = 'A';
    }

    // 3. Current Day of Week
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final currentDay = dayNames[now.weekday - 1];
    final currentMins = now.hour * 60 + now.minute;
    final currentTimeStr = DateFormat('hh:mm a').format(now);
    final currentDateStr = DateFormat('dd-MM-yyyy').format(now);

    final buffer = StringBuffer();

    // Weekend Check (Saturday & Sunday)
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      final gujDay = now.weekday == DateTime.saturday ? 'શનિવાર' : 'રવિવાર';
      if (isGujarati) {
        buffer.writeln('🏖️ **આજે વીકેન્ડ છે — કોલેજ બંધ છે ($gujDay)**');
        buffer.writeln('📅 આજની તારીખ: **$currentDateStr** | સમય: **$currentTimeStr**\n');
        buffer.writeln('📌 સરકારી પોલિટેકનિક હિંમતનગર IT વિભાગનો રેગ્યુલર સમયપત્રક **સોમવારથી શુક્રવાર** (10:30 AM થી 06:10 PM) ચાલે છે.');
        buffer.writeln('\n💡 સોમવારના પ્રથમ લેક્ચર જોવા માટે *"monday timetable"* અથવા *"સોમવારનો ટાઈમટેબલ"* પૂછો.');
      } else {
        buffer.writeln('🏖️ **Weekend Notice: College is Closed Today ($currentDay)**');
        buffer.writeln('📅 Date: **$currentDateStr** | Current Time: **$currentTimeStr**\n');
        buffer.writeln('📌 Regular academic lectures at Government Polytechnic Himmatnagar (IT Dept) run **Monday to Friday** (10:30 AM to 06:10 PM).');
        buffer.writeln('\n💡 Ask *"monday timetable"* or *"tomorrow timetable"* to see the upcoming schedule.');
      }
      return buffer.toString().trim();
    }

    // Filter today's timetable for target semester & division
    final todayEntries = entries.where((e) {
      if (e.day != currentDay) return false;
      if (e.semester != targetSem) return false;
      if (targetSem > 1 && targetDiv != null && e.division != null && e.division != targetDiv) return false;
      return true;
    }).toList();

    todayEntries.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

    final semLabel = targetSem == 1 ? 'Sem 1' : 'Sem $targetSem (Div $targetDiv)';

    // Before College Hours (< 10:30 AM = 630 mins)
    if (currentMins < 630) {
      final firstActivity = todayEntries.isNotEmpty ? todayEntries.first : null;
      if (isGujarati) {
        buffer.writeln('🌅 **કોલેજ હજી શરૂ થઈ નથી (College Not Started Yet)**');
        buffer.writeln('📅 **$currentDay ($currentDateStr)** | વર્તમાન સમય: **$currentTimeStr**');
        buffer.writeln('🏫 **વિભાગ:** IT — **$semLabel** | કોલેજ સમય: **10:30 AM થી 06:10 PM**\n');
        if (firstActivity != null) {
          final subName = getSubjectFullName(firstActivity.subject);
          buffer.writeln('🔔 **આજનો પ્રથમ લેક્ચર/લેબ (10:30 AM શરૂ થશે):**');
          buffer.writeln('• **વિષય:** ${firstActivity.subject} — $subName');
          buffer.writeln('• **પ્રકાર:** ${firstActivity.activityType}');
          buffer.writeln('• **સમય:** ${firstActivity.startTime} થી ${firstActivity.endTime}');
          if (firstActivity.room != null) buffer.writeln('• **રૂમ/લેબ:** ${firstActivity.room}');
          if (firstActivity.faculty != null) buffer.writeln('• **ફેકલ્ટી:** ${firstActivity.faculty}');
        }
      } else {
        buffer.writeln('🌅 **College Hours Have Not Begun Yet**');
        buffer.writeln('📅 **$currentDay ($currentDateStr)** | Current Time: **$currentTimeStr**');
        buffer.writeln('🏫 **Department:** IT — **$semLabel** | College Timing: **10:30 AM to 06:10 PM**\n');
        if (firstActivity != null) {
          final subName = getSubjectFullName(firstActivity.subject);
          buffer.writeln('🔔 **First Session of the Day (Starts at 10:30 AM):**');
          buffer.writeln('• **Subject:** ${firstActivity.subject} — $subName');
          buffer.writeln('• **Type:** ${firstActivity.activityType}');
          buffer.writeln('• **Timing:** ${firstActivity.startTime} – ${firstActivity.endTime}');
          if (firstActivity.room != null) buffer.writeln('• **Room/Lab:** ${firstActivity.room}');
          if (firstActivity.faculty != null) buffer.writeln('• **Faculty:** ${firstActivity.faculty}');
        }
      }
      return buffer.toString().trim();
    }

    // Lunch / Recess Break (1:30 PM to 2:00 PM = 810 to 840 mins)
    if (currentMins >= 810 && currentMins < 840) {
      final nextActivity = todayEntries.where((e) => e.startMinutes >= 840).firstOrNull;
      if (isGujarati) {
        buffer.writeln('🥪 **હમણાં રિસેસ / લંચ બ્રેક (Recess Break) ચાલુ છે!**');
        buffer.writeln('⏰ **બ્રેક સમય:** **01:30 PM થી 02:00 PM**');
        buffer.writeln('📅 **$currentDay** | વર્તમાન સમય: **$currentTimeStr** | **$semLabel**\n');
        if (nextActivity != null) {
          final subName = getSubjectFullName(nextActivity.subject);
          buffer.writeln('🔔 **લંચ પછીનો આગામી લેક્ચર (02:00 PM શરૂ થશે):**');
          buffer.writeln('• **વિષય:** ${nextActivity.subject} — $subName');
          buffer.writeln('• **પ્રકાર:** ${nextActivity.activityType}');
          buffer.writeln('• **સમય:** ${nextActivity.startTime} થી ${nextActivity.endTime}');
          if (nextActivity.room != null) buffer.writeln('• **રૂમ/લેબ:** ${nextActivity.room}');
          if (nextActivity.faculty != null) buffer.writeln('• **ફેકલ્ટી:** ${nextActivity.faculty}');
        }
      } else {
        buffer.writeln('🥪 **Currently Recess / Lunch Break (1:30 PM – 2:00 PM)**');
        buffer.writeln('⏰ **Break Duration:** **01:30 PM to 02:00 PM (30 minutes)**');
        buffer.writeln('📅 **$currentDay** | Current Time: **$currentTimeStr** | **$semLabel**\n');
        if (nextActivity != null) {
          final subName = getSubjectFullName(nextActivity.subject);
          buffer.writeln('🔔 **Next Lecture Resuming at 02:00 PM:**');
          buffer.writeln('• **Subject:** ${nextActivity.subject} — $subName');
          buffer.writeln('• **Type:** ${nextActivity.activityType}');
          buffer.writeln('• **Timing:** ${nextActivity.startTime} – ${nextActivity.endTime}');
          if (nextActivity.room != null) buffer.writeln('• **Room/Lab:** ${nextActivity.room}');
          if (nextActivity.faculty != null) buffer.writeln('• **Faculty:** ${nextActivity.faculty}');
        }
      }
      return buffer.toString().trim();
    }

    // Short Gap (4:00 PM to 4:10 PM = 960 to 970 mins)
    if (currentMins >= 960 && currentMins < 970) {
      final nextActivity = todayEntries.where((e) => e.startMinutes >= 970).firstOrNull;
      if (isGujarati) {
        buffer.writeln('☕ **હમણાં 10 મિનિટનો શોર્ટ બ્રેક (Short Break) છે (04:00 PM થી 04:10 PM)**');
        if (nextActivity != null) {
          buffer.writeln('🔔 **આગામી લેક્ચર 04:10 PM એ શરૂ થશે:** ${nextActivity.subject} (${nextActivity.startTime} – ${nextActivity.endTime})');
        }
      } else {
        buffer.writeln('☕ **10-Minute Transition Gap (04:00 PM – 04:10 PM)**');
        if (nextActivity != null) {
          buffer.writeln('🔔 **Next Session Resumes at 04:10 PM:** ${nextActivity.subject} (${nextActivity.startTime} – ${nextActivity.endTime})');
        }
      }
      return buffer.toString().trim();
    }

    // After College Hours (> 6:10 PM = 1090 mins)
    if (currentMins >= 1090) {
      if (isGujarati) {
        buffer.writeln('🌙 **આજના કોલેજ લેક્ચર્સ પૂર્ણ થઈ ગયા છે (College Hours Over for Today)**');
        buffer.writeln('📅 **$currentDay ($currentDateStr)** | વર્તમાન સમય: **$currentTimeStr**');
        buffer.writeln('🏫 **IT — $semLabel** | દૈનિક સમય: **10:30 AM થી 06:10 PM**\n');
        buffer.writeln('💡 આવતીકાલનો ટાઈમટેબલ જોવા માટે *"tomorrow timetable"* અથવા *"આવતીકાલનો ટાઈમટેબલ"* પૂછો.');
      } else {
        buffer.writeln('🌙 **College Hours Have Concluded for Today**');
        buffer.writeln('📅 **$currentDay ($currentDateStr)** | Current Time: **$currentTimeStr**');
        buffer.writeln('🏫 **IT — $semLabel** | Regular Schedule: **10:30 AM to 06:10 PM**\n');
        buffer.writeln('💡 Ask *"tomorrow timetable"* to see the full schedule for tomorrow.');
      }
      return buffer.toString().trim();
    }

    // Find Ongoing Entries
    final currentEntries = todayEntries.where((e) => e.isOngoing(currentMins)).toList();
    // Find Upcoming Entries today
    final upcomingEntries = todayEntries.where((e) => e.isUpcoming(currentMins) && !e.isOngoing(currentMins)).toList();
    final nextEntry = upcomingEntries.isNotEmpty ? upcomingEntries.first : null;

    if (currentEntries.isNotEmpty) {
      if (isGujarati) {
        buffer.writeln('🟢 **હમણાં ચાલુ લેક્ચર / સેશન (Current Ongoing Class):**');
        buffer.writeln('📅 **$currentDay** | વર્તમાન સમય: **$currentTimeStr** | **$semLabel**\n');

        if (currentEntries.length == 1) {
          final cur = currentEntries.first;
          final subName = getSubjectFullName(cur.subject);
          buffer.writeln('📚 **વિષય:** **${cur.subject}** — $subName');
          buffer.writeln('📋 **પ્રકાર:** ${cur.activityType}');
          buffer.writeln('⏰ **સમય:** **${cur.startTime} થી ${cur.endTime}**');
          if (cur.room != null) buffer.writeln('🏛️ **રૂમ / લેબ:** **${cur.room}**');
          if (cur.faculty != null) buffer.writeln('👨‍🏫 **ફેકલ્ટી:** **${cur.faculty}**');
          if (cur.batch != null) buffer.writeln('👥 **બેચ:** **${cur.batch}**');
        } else {
          // Multiple batch lab running simultaneously
          buffer.writeln('🧪 **પ્રાયોગિક સેશન / લેબ બેચ પ્રમાણે ચાલુ છે (Lab in Progress):**');
          buffer.writeln('⏰ **સમય:** **${currentEntries.first.startTime} થી ${currentEntries.first.endTime}**\n');
          for (final cur in currentEntries) {
            final subName = getSubjectFullName(cur.subject);
            final batchStr = cur.batch != null ? ' (બેચ ${cur.batch})' : '';
            buffer.writeln('• **${cur.subject}**$batchStr — રૂમ: **${cur.room ?? "-"}** | ફેકલ્ટી: **${cur.faculty ?? "-"}** ($subName)');
          }
        }

        if (nextEntry != null) {
          final nextSubName = getSubjectFullName(nextEntry.subject);
          buffer.writeln('\n⏩ **આગામી લેક્ચર (Next Lecture):**');
          buffer.writeln('• **${nextEntry.subject}** ($nextSubName)');
          buffer.writeln('• **સમય:** **${nextEntry.startTime} થી ${nextEntry.endTime}**');
          if (nextEntry.room != null) buffer.writeln('• **રૂમ:** ${nextEntry.room}');
          if (nextEntry.faculty != null) buffer.writeln('• **ફેકલ્ટી:** ${nextEntry.faculty}');
        } else {
          buffer.writeln('\n🏁 આ સેશન પછી આજના કોલેજ લેક્ચર્સ પૂર્ણ થશે.');
        }
      } else {
        buffer.writeln('🟢 **Current Ongoing Lecture / Lab Session:**');
        buffer.writeln('📅 **$currentDay** | Current Time: **$currentTimeStr** | **$semLabel**\n');

        if (currentEntries.length == 1) {
          final cur = currentEntries.first;
          final subName = getSubjectFullName(cur.subject);
          buffer.writeln('📚 **Subject:** **${cur.subject}** — $subName');
          buffer.writeln('📋 **Activity:** ${cur.activityType}');
          buffer.writeln('⏰ **Slot:** **${cur.startTime} – ${cur.endTime}**');
          if (cur.room != null) buffer.writeln('🏛️ **Room/Lab:** **${cur.room}**');
          if (cur.faculty != null) buffer.writeln('👨‍🏫 **Faculty:** **${cur.faculty}**');
          if (cur.batch != null) buffer.writeln('👥 **Batch:** **${cur.batch}**');
        } else {
          buffer.writeln('🧪 **Practical Lab Sessions Running (Batch-wise):**');
          buffer.writeln('⏰ **Slot:** **${currentEntries.first.startTime} – ${currentEntries.first.endTime}**\n');
          for (final cur in currentEntries) {
            final subName = getSubjectFullName(cur.subject);
            final batchStr = cur.batch != null ? ' [Batch ${cur.batch}]' : '';
            buffer.writeln('• **${cur.subject}**$batchStr — Room: **${cur.room ?? "-"}** | Faculty: **${cur.faculty ?? "-"}** ($subName)');
          }
        }

        if (nextEntry != null) {
          final nextSubName = getSubjectFullName(nextEntry.subject);
          buffer.writeln('\n⏩ **Upcoming Next Session:**');
          buffer.writeln('• **${nextEntry.subject}** ($nextSubName)');
          buffer.writeln('• **Slot:** **${nextEntry.startTime} – ${nextEntry.endTime}**');
          if (nextEntry.room != null) buffer.writeln('• **Room:** ${nextEntry.room}');
          if (nextEntry.faculty != null) buffer.writeln('• **Faculty:** ${nextEntry.faculty}');
        } else {
          buffer.writeln('\n🏁 This is the final scheduled session for today.');
        }
      }
    } else {
      // Free slot or gap
      if (isGujarati) {
        buffer.writeln('ℹ️ **હમણાં કોઈ નિયત લેક્ચર સ્લોટ નથી ($currentTimeStr)**');
        buffer.writeln('📅 **$currentDay** | **$semLabel**\n');
        if (nextEntry != null) {
          final nextSubName = getSubjectFullName(nextEntry.subject);
          buffer.writeln('🔔 **આગામી સત્ર:** **${nextEntry.subject}** ($nextSubName)');
          buffer.writeln('⏰ **સમય:** **${nextEntry.startTime} થી ${nextEntry.endTime}**');
          if (nextEntry.room != null) buffer.writeln('🏛️ **રૂમ:** ${nextEntry.room}');
        }
      } else {
        buffer.writeln('ℹ️ **No Scheduled Lecture at this Moment ($currentTimeStr)**');
        buffer.writeln('📅 **$currentDay** | **$semLabel**\n');
        if (nextEntry != null) {
          final nextSubName = getSubjectFullName(nextEntry.subject);
          buffer.writeln('🔔 **Next Scheduled Session:** **${nextEntry.subject}** ($nextSubName)');
          buffer.writeln('⏰ **Timing:** **${nextEntry.startTime} – ${nextEntry.endTime}**');
          if (nextEntry.room != null) buffer.writeln('🏛️ **Room:** ${nextEntry.room}');
        }
      }
    }

    return buffer.toString().trim();
  }

  /// Resolves full daily timetable schedule
  static String getDailyScheduleResponse({
    required String userText,
    DateTime? date,
    String? dayName,
    int? studentSemester,
    String? studentDivision,
    String? language,
  }) {
    final bool isGujarati = language == 'GUJARATI' || RegExp(r'[\u0A80-\u0AFF]').hasMatch(userText);
    final now = date ?? DateTime.now();
    final lower = userText.toLowerCase();

    // 1. Resolve Day
    String targetDay = dayName ?? 'Monday';
    if (dayName == null) {
      if (lower.contains('today') || lower.contains('આજ')) {
        final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        targetDay = dayNames[now.weekday - 1];
      } else if (lower.contains('tomorrow') || lower.contains('આવતીકાલ')) {
        final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        final nextW = (now.weekday % 7) + 1;
        targetDay = dayNames[nextW - 1];
      } else if (lower.contains('monday') || lower.contains('સોમવાર')) {
        targetDay = 'Monday';
      } else if (lower.contains('tuesday') || lower.contains('મંગળવાર')) {
        targetDay = 'Tuesday';
      } else if (lower.contains('wednesday') || lower.contains('બુધવાર')) {
        targetDay = 'Wednesday';
      } else if (lower.contains('thursday') || lower.contains('ગુરુવાર')) {
        targetDay = 'Thursday';
      } else if (lower.contains('friday') || lower.contains('શુક્રવાર')) {
        targetDay = 'Friday';
      } else {
        final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        targetDay = (now.weekday >= 1 && now.weekday <= 5) ? dayNames[now.weekday - 1] : 'Monday';
      }
    }

    // 2. Resolve Semester & Division
    int targetSem = studentSemester ?? 5;
    if (lower.contains('sem 1') || lower.contains('sem-1') || lower.contains('semester 1') || lower.contains('1st sem') || lower.contains('sem1')) {
      targetSem = 1;
    } else if (lower.contains('sem 3') || lower.contains('sem-3') || lower.contains('semester 3') || lower.contains('3rd sem') || lower.contains('sem3')) {
      targetSem = 3;
    } else if (lower.contains('sem 5') || lower.contains('sem-5') || lower.contains('semester 5') || lower.contains('5th sem') || lower.contains('sem5')) {
      targetSem = 5;
    }

    String? targetDiv = studentDivision;
    if (lower.contains('div a') || lower.contains('division a')) {
      targetDiv = 'A';
    } else if (lower.contains('div b') || lower.contains('division b')) {
      targetDiv = 'B';
    }
    if (targetSem > 1 && targetDiv == null) targetDiv = 'A';

    final semLabel = targetSem == 1 ? 'Sem 1' : 'Sem $targetSem (Div $targetDiv)';

    if (targetDay == 'Saturday' || targetDay == 'Sunday') {
      return isGujarati
          ? '🏖️ **$targetDay એ કોલેજ બંધ છે (Weekend Holiday)**. નિયમિત વર્ગો સોમવારથી શુક્રવાર સુધી ચાલે છે.'
          : '🏖️ **College is Closed on $targetDay (Weekend Holiday)**. Academic sessions run Monday to Friday.';
    }

    final dayEntries = entries.where((e) {
      if (e.day != targetDay) return false;
      if (e.semester != targetSem) return false;
      if (targetSem > 1 && targetDiv != null && e.division != null && e.division != targetDiv) return false;
      return true;
    }).toList();

    dayEntries.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

    final buffer = StringBuffer();
    if (isGujarati) {
      buffer.writeln('📅 **સરકારી પોલિટેકનિક હિંમતનગર — IT વિભાગ દૈનિક સમયપત્રક**');
      buffer.writeln('📋 **વાર:** **$targetDay** | **વિભાગ:** **$semLabel**\n');
      buffer.writeln('| સમય | પ્રકાર | વિષય | ફેકલ્ટી | રૂમ / લેબ | બેચ |');
      buffer.writeln('| :--- | :--- | :--- | :--- | :--- | :--- |');
      for (final e in dayEntries) {
        final batchStr = e.batch ?? 'સર્વ';
        final roomStr = e.room ?? '-';
        final facStr = e.faculty ?? '-';
        buffer.writeln('| **${e.startTime} - ${e.endTime}** | ${e.activityType} | **${e.subject}** | $facStr | $roomStr | $batchStr |');
      }
      buffer.writeln('\n🥪 **નોંધ:** બપોરે 01:30 થી 02:00 લંચ/રિસેસ બ્રેક છે. 04:00 થી 04:10 શોર્ટ બ્રેક છે.');
    } else {
      buffer.writeln('📅 **Government Polytechnic, Himatnagar — IT Department Timetable**');
      buffer.writeln('📋 **Day:** **$targetDay** | **Scope:** **$semLabel**\n');
      buffer.writeln('| Time Slot | Type | Subject | Faculty | Room / Lab | Batch |');
      buffer.writeln('| :--- | :--- | :--- | :--- | :--- | :--- |');
      for (final e in dayEntries) {
        final batchStr = e.batch ?? 'All';
        final roomStr = e.room ?? '-';
        final facStr = e.faculty ?? '-';
        buffer.writeln('| **${e.startTime} – ${e.endTime}** | ${e.activityType} | **${e.subject}** | $facStr | $roomStr | $batchStr |');
      }
      buffer.writeln('\n🥪 **Schedule Notes:** Lunch/Recess Break is 01:30 PM – 02:00 PM. Short transition break is 04:00 PM – 04:10 PM.');
    }

    return buffer.toString().trim();
  }
}

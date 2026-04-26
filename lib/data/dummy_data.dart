import '../core/utils/date_utils_ext.dart';
import '../models/schedule_model.dart';
import '../models/notice_model.dart';

/// SCHEDULES DATA
final List<ScheduleItem> schedules = [
  ScheduleItem(
    id: '1',
    subject: 'Data Structures and Algorithms',
    courseCode: 'CS201',
    teacher: 'Dr. Smith',
    room: 'Room 101',
    startTime: '09:00',
    endTime: '10:30',
    day: 'Monday',
    colorHex: 0xFF42A5F5,
    section: 'A',
    status: 'active',
    createdBy: 'admin123',
  ),
  ScheduleItem(
    id: '2',
    subject: 'Operating Systems',
    courseCode: 'CS301',
    teacher: 'Prof. Johnson',
    room: 'Room 202',
    startTime: '11:00',
    endTime: '12:30',
    day: 'Tuesday',
    colorHex: 0xFF66BB6A,
    section: 'B',
    status: 'active',
    createdBy: 'admin123',
  ),
];

/// NOTICES DATA
final List<NoticeItem> notices = [
  NoticeItem(
    id: '1',
    title: 'Mid-term Exam Schedule',
    description: 'Mid-term exams will start from next week.',
    time: '10:00 AM',
    date: DateTime(2025, 4, 28),
    postedBy: 'CR',
    type: NoticeType.urgent,
  ),
  NoticeItem(
    id: '2',
    title: 'Class Cancelled',
    description: 'DSA class is cancelled today.',
    time: '08:00 AM',
    date: DateTime(2025, 4, 24),
    postedBy: 'CR',
    type: NoticeType.department,
  ),
];

// QUERY HELPERS

/// Returns schedules matching the day-of-week of the given date.
List<ScheduleItem> getSchedulesForDate(DateTime date) {
  const dayNames = [
    'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];
  final dayName = dayNames[date.weekday - 1];
  return schedules
      .where((s) => s.day?.toLowerCase() == dayName.toLowerCase())
      .toList();
}

/// Returns notices pinned to specific demo dates.
List<NoticeItem> getNoticesForDate(DateTime date) {
  return notices
      .where((n) => n.date != null && AppDateUtils.isSameDay(n.date!, date))
      .toList();
}
import '../core/utils/date_utils_ext.dart';
import '../models/schedule_model.dart';
import '../models/notice_model.dart';


/// TODAY'S SCHEDULE (Dashboard)

final List<ScheduleItem> todaySchedule = [
  ScheduleItem(
    subject: 'Data Structures',
    courseCode: 'CSE-2101',
    teacher: 'Dr. A. Rahman',
    room: 'Room 302',
    startTime: '08:50 AM',
    endTime: '10:30 AM',
    colorHex: 0xFF42A5F5,
  ),
  ScheduleItem(
    subject: 'Discrete Mathematics',
    courseCode: 'CSE-2103',
    teacher: 'Prof. N. Sultana',
    room: 'Room 205',
    startTime: '10:50 AM',
    endTime: '11:40 AM',
    colorHex: 0xFF66BB6A,
  ),
  ScheduleItem(
    subject: 'Digital Logic Design',
    courseCode: 'CSE-2105',
    teacher: 'Dr. S. Hasan',
    room: 'Lab DL-1',
    startTime: '02:30 PM',
    endTime: '05:00 PM',
    colorHex: 0xFFFFA726,
  ),
];


/// FULL WEEK SCHEDULE

final List<ScheduleItem> fullSchedule = [
  // Monday
  ScheduleItem(
    subject: 'Data Structures',
    courseCode: 'CSE-2101',
    teacher: 'Dr. A. Rahman',
    room: 'Room 302',
    startTime: '08:50 AM',
    endTime: '10:30 AM',
    day: 'Monday',
    colorHex: 0xFF42A5F5,
  ),
  ScheduleItem(
    subject: 'Discrete Mathematics',
    courseCode: 'CSE-2103',
    teacher: 'Prof. N. Sultana',
    room: 'Room 205',
    startTime: '10:30 AM',
    endTime: '11:40 AM',
    day: 'Monday',
    colorHex: 0xFF66BB6A,
  ),

  // Tuesday
  ScheduleItem(
    subject: 'Object Oriented Programming',
    courseCode: 'CSE-2102',
    teacher: 'Dr. M. Islam',
    room: 'Room 401',
    startTime: '08:50 AM',
    endTime: '10:30 AM',
    day: 'Tuesday',
    colorHex: 0xFFAB47BC,
  ),
  ScheduleItem(
    subject: 'Digital Logic Design (Lab)',
    courseCode: 'CSE-2105',
    teacher: 'Dr. S Hasan',
    room: 'Lab DL-1',
    startTime: '02:30 PM',
    endTime: '04:10 PM',
    day: 'Tuesday',
    colorHex: 0xFFFF7043,
  ),

  // Wednesday
  ScheduleItem(
    subject: 'Data Structures (Lab)',
    courseCode: 'CSE-2101',
    teacher: 'Mr. T. Ahmed',
    room: 'Lab DS-2',
    startTime: '08:50 AM',
    endTime: '10:30 AM',
    day: 'Wednesday',
    colorHex: 0xFF29B6F6,
  ),

  ScheduleItem(
    subject: 'Discrete Mathematics',
    courseCode: 'CSE-2103',
    teacher: 'Prof. N. Sultana',
    room: 'Room 205',
    startTime: '10:50 AM',
    endTime: '01:20 PM',
    day: 'Wednesday',
    colorHex: 0xFF66BB6A,
  ),

  // Saturday
  ScheduleItem(
    subject: 'Data Structures (Lab)',
    courseCode: 'CSE-2101',
    teacher: 'Dr. A. Rahman',
    room: 'Lab CS-2',
    startTime: '08:50 AM',
    endTime: '10:30 AM',
    day: 'Saturday',
    colorHex: 0xFF42A5F5,
  ),
  ScheduleItem(
    subject: 'Discrete Mathematics',
    courseCode: 'CSE-2103',
    teacher: 'Prof. N. Sultana',
    room: 'Room 205',
    startTime: '11:40 AM',
    endTime: '12:30 PM',
    day: 'Saturday',
    colorHex: 0xFF66BB6A,
  ),

  // Sunday
  ScheduleItem(
    subject: 'Discrete Mathematics',
    courseCode: 'CSE-2103',
    teacher: 'Prof. N. Sultana',
    room: 'Room 205',
    startTime: '10:50 AM',
    endTime: '12:30 PM',
    day: 'Sunday',
    colorHex: 0xFF66BB6A,
  ),

  ScheduleItem(
    subject: 'Digital Logic Design',
    courseCode: 'CSE-2105',
    teacher: 'Dr. S. Hasan',
    room: 'Lab DL-1',
    startTime: '02:30 PM',
    endTime: '05:00 PM',
    day: 'Sunday',
    colorHex: 0xFFFFA726,
  ),
  ScheduleItem(
    subject: 'Object Oriented Programming',
    courseCode: 'CSE-2102',
    teacher: 'Dr. M. Islam',
    room: 'Room 401',
    startTime: '12:30 AM',
    endTime: '01:20 PM',
    day: 'Sunday',
    colorHex: 0xFFAB47BC,
  ),
];

/// NOTICES DATA (UPDATED)

//final _now = DateTime.now();

final List<NoticeItem> notices = [
  NoticeItem(
    title: 'Class Rescheduled - SDP Lab',
    description:
    'Tomorrow\'s Software Development Project lab has been rescheduled from 10:50 AM to 11:20 AM. Room remains the same (Lab 305).',
    time: '2h ago',
    postedBy: 'CR - CSE 23',
    type: NoticeType.urgent,
  ),
  NoticeItem(
    title: 'Assignment Submission Reminder',
    description:
    'DBMS assignment (Database Design Project) is due on December 20, 2025. Submit via email to the course instructor.',
    time: '1d ago',
    postedBy: 'Admin - CSE Dept',
    type: NoticeType.department,
  ),
  NoticeItem(
    title: 'Winter Break Announcement',
    description:
    'University will be closed for winter break from December 24 to January 2. Campus reopens on January 3, 2026.',
    time: '3d ago',
    postedBy: 'RUET Administration',
    type: NoticeType.university,
  ),
  NoticeItem(
    title: 'Mid-Term Exam Schedule Published',
    description:
    'The mid-term examination schedule for all 2nd year students has been published. Please check the notice board or student portal.',
    time: '5d ago',
    postedBy: 'Exam Controller',
    type: NoticeType.department,
  ),
  NoticeItem(
    title: 'Lab Equipment Maintenance',
    description:
    'Computer Lab 3 will be closed for maintenance from March 15-17. Please use alternative labs during this period.',
    time: '1w ago',
    postedBy: 'Lab Administrator',
    type: NoticeType.department,
  ),
  NoticeItem(
    title: 'Internet Outage Notice',
    description:
    'Campus-wide internet service will be temporarily unavailable on Saturday, March 20 from 12:00 AM to 6:00 AM for system upgrades.',
    time: '1w ago',
    postedBy: 'IT Department',
    type: NoticeType.urgent,
  ),
  NoticeItem(
    title: 'Workshop on Competitive Programming',
    description:
    'A hands-on workshop on Competitive Programming will be held next week in the central seminar hall. Registration required.',
    time: '2w ago',
    postedBy: 'RAPL Programming Club',
    type: NoticeType.university,
  ),
  NoticeItem(
    title: 'Semester Fee Deadline',
    description:
    'Last date for semester fee payment is 25th March. Late payment will incur a fine of 500 BDT.',
    time: '2w ago',
    postedBy: 'Accounts Department',
    type: NoticeType.university,
  ),
];

// QUERY HELPERS

List<ScheduleItem> getSchedulesForDate(DateTime date) {
  final dayName = AppDateUtils.scheduleDay(date);
  return fullSchedule.where((item) => item.day == dayName).toList();
}

/// Returns notices pinned to specific demo dates.
List<NoticeItem> getNoticesForDate(DateTime date) {
  return notices
      .where((n) => n.date != null && AppDateUtils.isSameDay(n.date!, date))
      .toList();
}

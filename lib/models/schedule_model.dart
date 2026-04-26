class ScheduleItem {
  final String? id;
  final String subject;
  final String courseCode;
  final String teacher;
  final String room;
  final String startTime;
  final String endTime;
  final String? day;
  final int colorHex;
  final String section;
  final String status;
  final String createdBy;

  ScheduleItem({
    required this.id,
    required this.subject,
    required this.courseCode,
    required this.teacher,
    required this.room,
    required this.startTime,
    required this.endTime,
    this.day,
    required this.colorHex,
    required this.section,
    required this.status,
    required this.createdBy,
  });

  // Add these methods:
  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'courseCode': courseCode,
      'teacher': teacher,
      'room': room,
      'startTime': startTime,
      'endTime': endTime,
      'day': day,
      'colorHex': colorHex,
      'section': section,
      'status': status,
      'createdBy': createdBy,
    };
  }

  factory ScheduleItem.fromMap(Map<String, dynamic> map, String id) {
    return ScheduleItem(
      id: id,
      subject: map['subject'] ?? '',
      courseCode: map['courseCode'] ?? '',
      teacher: map['teacher'] ?? '',
      room: map['room'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      day: map['day'],
      colorHex: map['colorHex'] ?? 0xFF000000,
      section: map['section'] ?? '',
      status: map['status'] ?? '',
      createdBy: map['createdBy'] ?? '',
    );
  }
}
import 'package:flutter/material.dart';

class NoticeItem {
  final String title;
  final String description;
  final String time;      // human-readable label
  final DateTime? date;   //calendar-filtering
  final String postedBy;
  final NoticeType type;

  NoticeItem({
    required this.title,
    required this.description,
    required this.time,
    this.date,
    required this.postedBy,
    this.type = NoticeType.department,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'time': time,
      'date': date?.toIso8601String(),
      'postedBy': postedBy,
      'type': type.name,
    };
  }

  factory NoticeItem.fromMap(Map<String, dynamic> map) {
    return NoticeItem(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      time: map['time'] ?? '',
      date: map['date'] != null ? DateTime.tryParse(map['date']) : null,
      postedBy: map['postedBy'] ?? '',
      type: NoticeType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => NoticeType.department,
      ),
    );
  }
}

enum NoticeType { urgent, department, university , section}

extension NoticeTypeExtension on NoticeType {
  String get label {
    switch (this) {
      case NoticeType.urgent:
        return 'URGENT';
      case NoticeType.department:
        return 'DEPARTMENT';
      case NoticeType.university:
        return 'UNIVERSITY';
      case NoticeType.section:
        return 'SECTION';
    }
  }

  Color get color {
    switch (this) {
      case NoticeType.urgent:
        return const Color(0xFFFF9800); //orange
      case NoticeType.department:
        return const Color(0xFF1E88E5); //blue
      case NoticeType.university:
        return const Color(0xFF9C27B0); //purple
      case NoticeType.section:
        return const Color(0xFF43A047); //green 
    }
  }

  Color get backgroundColor => color.withValues(alpha: 0.1);
}

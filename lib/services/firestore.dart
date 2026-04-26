import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruethive/core/state/role_provider.dart';
import 'package:ruethive/models/app_user.dart';
import 'package:ruethive/models/notice_model.dart';
import '../models/schedule_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //funtion to upload Schedule


  Future<void> uploadSchedule(ScheduleItem schedule) async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    await _db.collection("Schedules").add({
      ...schedule.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': user?.uid,
    });

  } catch (e) {
    print("Error: $e");
  }
}

 // function to get Schedule
  Stream<List<ScheduleItem>> getSchedulesByDay(String day) {
  return _db
      .collection('Schedules')
      .where('day', isEqualTo: day)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => ScheduleItem.fromMap(doc.data(), doc.id))
            .toList();
      });
}

 


Stream<List<ScheduleItem>> getAllSchedules() {
  return _db.collection('Schedules').snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => ScheduleItem.fromMap(doc.data(), doc.id))
        .toList();
  });
}

  //funtion to upload notice
  Future<void> uploadNotice(NoticeItem notice) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection("Notices").add({
        ...notice.toMap(),
        "createdBy": user?.uid,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  // funtion to get notice

  Stream<List<NoticeItem>> getAllNotices() {
    return _db
        .collection('Notices')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return NoticeItem.fromMap(data, doc.id);
          }).toList(),
        );
  }

  // get notices & schudules by cr or admin

  Stream<List<NoticeItem>> getNoticesByUser(String userId) {
    return _db
        .collection('Notices')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NoticeItem.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  //DELETE NOTICE

  Future<void> deleteNotice(String id) async {
    await _db.collection('Notices').doc(id).delete();
  }

  //UPDATE NOTICE
  Future<void> updateNotice(String id, Map<String, dynamic> data) async {
    await _db.collection('Notices').doc(id).update(data);
  }
//DELETE SCHEDULE
Future<void> deleteSchedule(String id) async {
  await _db.collection('Schedules').doc(id).delete();
}
// UPDATE SCHEDULE
Future<void> updateSchedule(String id, Map<String, dynamic> data) async {
  await _db.collection('Schedules').doc(id).update(data);
  
}


  // Admin part
  Future<void> markNoticeUrgent(String id) async {
    try {
      await _db.collection('Notices').doc(id).update({
        'type': NoticeType.urgent.name,
      });
    } catch (e) {
      print("Error marking urgent: $e");
    }
  }
//  uploadUser
  Future<void> uploadUser(AppUser user) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      await _db.collection("users").add({
        ...{
          'name': user.name,
          'studentId': user.studentId,
          'email': user.email,
          'department': user.department,
          'batch': user.batch,
          'section': user.section,
          'memberSince': user.memberSince,
          'role': user.role.name,
        },
        "createdBy": currentUser?.uid,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error uploading user: $e");
    }
  }

//get user

Stream<List<AppUser>> getAllUsers() {
  return _db.collection('users')
  .snapshots()
  .map((snapshot) {
  return snapshot.docs.map((doc) {
  return AppUser.fromMap(doc.data(), doc.id);
    })
    .toList();
  });
}

// DELETE USER
Future<void> deleteUser(String docId) async {
  await _db.collection('users').doc(docId).delete();
}

// UPDATE USER
Future<void> updateUser(String docId, Map<String, dynamic> data) async {
  await _db.collection('users').doc(docId).update(data);
}
// changeUserRole
Future<void> changeUserRole(String docId, UserRole role) async {
  try {
    await _db.collection('users').doc(docId).update({
      'role': role.name,
    });
  } catch (e) {
    print("Error updating role: $e");
  }
}
 Stream<Map<String, int>> getUserStats() {
    return _db.collection('users').snapshots().map((snapshot) {
      int total = snapshot.docs.length;
      int students = 0;
      int cr = 0;
      int admin = 0;

      for (var doc in snapshot.docs) {
        final role = doc['role'];

        if (role == 'student') students++;
        else if (role == 'cr') cr++;
        else if (role == 'admin') admin++;
      }

      return {
        'total': total,
        'students': students,
        'cr': cr,
        'admin': admin,
      };
    });
  }


// get recent activities (new schedules, new users, new notices)
  Stream<List<Map<String, dynamic>>> getRecentActivities() {
  final schedulesStream = _db
      .collection('Schedules')
      .orderBy('createdAt', descending: true)
      .limit(5)
      .snapshots();

  final usersStream = _db
      .collection('users')
      .orderBy('createdAt', descending: true)
      .limit(5)
      .snapshots();

  final notificationsStream = _db
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .limit(5)
      .snapshots();

  return schedulesStream.asyncMap((scheduleSnap) async {
    final userSnap = await usersStream.first;
    final notificationSnap = await notificationsStream.first;

    // schedules
    final schedules = scheduleSnap.docs.map((doc) {
      final data = doc.data();
      return {
        'type': 'schedule',
        'msg': '${data['subject']} schedule added',
        'time': data['createdAt'],
      };
    }).toList();

    // users
    final users = userSnap.docs.map((doc) {
      final data = doc.data();
      return {
        'type': 'user',
        'msg': 'New user: ${data['name']} registered',
        'time': data['createdAt'],
      };
    }).toList();

    // notifications
    final notifications = notificationSnap.docs.map((doc) {
      final data = doc.data();
      return {
        'type': 'notification',
        'msg': data['message'],
        'time': data['createdAt'],
      };
    }).toList();

    final all = [...schedules, ...users, ...notifications];

    // sort latest first
    all.sort((a, b) {
      final t1 = a['time'] as Timestamp;
      final t2 = b['time'] as Timestamp;
      return t2.compareTo(t1);
    });

    return all.take(6).toList();
  });
}


}



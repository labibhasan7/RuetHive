import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruethive/models/notice_model.dart';
import '../models/schedule_model.dart';

class FirestoreService {
final FirebaseFirestore _db = FirebaseFirestore.instance;


//funtion to upload Schedule

Future<void> uploadSchedule(ScheduleItem schedule) async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection("Schedules")
        .add(schedule.toMap());

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
        .map((doc) => ScheduleItem.fromMap(doc.data()))
        .toList();
    });
  }
 Stream<List<ScheduleItem>> getAllSchedules() {
    return _db
      .collection('Schedules')
      .snapshots()
      .map((snapshot) {
      return snapshot.docs
        .map((doc) => ScheduleItem.fromMap(doc.data()))
        .toList();
    });
  }
//funtion to upload notice
Future<void> uploadNotice(NoticeItem notice) async {
   
    try {
     await FirebaseFirestore.instance
          .collection("Notices")
          .add(notice.toMap());
          
    } 
    
    catch (e) {
      print("Error: $e");
    }
  }


// funtion to get notice


 Stream<List<NoticeItem>> getAllNotices() {
  return _db
      .collection('Notices')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => NoticeItem.fromMap(doc.data()))
        .toList();
  });
}

Stream<List<NoticeItem>> getNoticesByType(NoticeType type) {
  return _db
      .collection('Notices')
      .where('type', isEqualTo: type.name)
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => NoticeItem.fromMap(doc.data()))
        .toList();
  });
}




}





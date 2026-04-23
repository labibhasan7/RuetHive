import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';

class FirestoreService {
final FirebaseFirestore _db = FirebaseFirestore.instance;
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


}
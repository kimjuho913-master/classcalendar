import 'package:class_calendar/model/category_color.dart';
import 'package:class_calendar/model/schedule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _schedulesCollection =
  FirebaseFirestore.instance.collection('schedules');
  final CollectionReference _colorsCollection =
  FirebaseFirestore.instance.collection('categoryColors');

  // 스케줄 추가 (수정된 부분)
  Future<void> addSchedule(Schedule schedule) {
    // schedule 객체에 포함된 id를 사용하여 문서를 생성합니다.
    return _schedulesCollection.doc(schedule.id).set(schedule.toMap());
  }

  // 스케줄 수정
  Future<void> updateSchedule(Schedule schedule) {
    return _schedulesCollection.doc(schedule.id).update(schedule.toMap());
  }

  // 스케줄 삭제
  Future<void> deleteSchedule(String scheduleId) {
    return _schedulesCollection.doc(scheduleId).delete();
  }

  // 모든 스케줄 실시간 조회 (캘린더 이벤트 마커용)
  Stream<List<Schedule>> watchAllSchedules() {
    return _schedulesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Schedule.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // 특정 날짜의 스케줄 실시간 조회
  Stream<List<Schedule>> watchSchedules(DateTime date) {
    // 저장된 'date' 필드와 정확히 일치하는 타임스탬프를 쿼리합니다.
    // date는 이미 UTC 자정 기준이므로 시간대 문제가 발생하지 않습니다.
    return _schedulesCollection
        .where('date', isEqualTo: Timestamp.fromDate(date))
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Schedule.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // 특정 ID의 스케줄 한번만 가져오기 (수정 시 초기 데이터 로드용)
  Future<Schedule?> getScheduleById(String scheduleId) async {
    final doc = await _schedulesCollection.doc(scheduleId).get();
    if (doc.exists) {
      return Schedule.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // 색상 카테고리 가져오기
  Future<List<CategoryColor>> getCategoryColors() async {
    final snapshot = await _colorsCollection.get();
    return snapshot.docs.map((doc) {
      return CategoryColor.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // (앱 최초 실행 시 한 번만 호출) 기본 색상 추가
  Future<void> addDefaultColors(List<String> hexCodes) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final hexCode in hexCodes) {
      final docRef = _colorsCollection.doc();
      batch.set(docRef, {'hexCode': hexCode});
    }
    await batch.commit();
  }
}
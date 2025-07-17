import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String id; // Firestore 문서 ID
  final String content;
  final DateTime date;
  final int startTime;
  final int endTime;
  final String colorHexCode; // 색상 Hex 코드 직접 저장
  final DateTime createdAt;

  Schedule({
    required this.id,
    required this.content,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.colorHexCode,
    required this.createdAt,
  });

  // Firestore 데이터(Map)를 Schedule 객체로 변환
  factory Schedule.fromMap(String id, Map<String, dynamic> map) {
    return Schedule(
      id: id,
      content: map['content'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      startTime: map['startTime'] ?? 0,
      endTime: map['endTime'] ?? 0,
      colorHexCode: map['colorHexCode'] ?? 'd92417', // 기본값: 빨강
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Schedule 객체를 Firestore에 저장할 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'colorHexCode': colorHexCode,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
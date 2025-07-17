class CategoryColor {
  final String id; // Firestore 문서 ID
  final String hexCode;

  CategoryColor({
    required this.id,
    required this.hexCode,
  });

  // Firestore 데이터(Map)를 CategoryColor 객체로 변환
  factory CategoryColor.fromMap(String id, Map<String, dynamic> map) {
    return CategoryColor(
      id: id,
      hexCode: map['hexCode'] ?? '',
    );
  }

  // CategoryColor 객체를 Firestore에 저장할 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'hexCode': hexCode,
    };
  }
}
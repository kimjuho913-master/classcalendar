import 'package:class_calendar/firebase_options.dart';
import 'package:class_calendar/screen/home_screen.dart';
import 'package:class_calendar/services/firestore_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Flutter 프레임워크가 앱을 실행할 준비가 될 때까지 기다립니다.
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 서비스를 초기화합니다.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 날짜 및 시간 형식 라이브러리를 초기화합니다.
  await initializeDateFormatting();

  final firestoreService = FirestoreService();

  // Firestore에 색상 데이터가 없으면 기본 색상들을 추가합니다.
  final colors = await firestoreService.getCategoryColors();
  if (colors.isEmpty) {
    const defaultColors = [

      'ff0033',

      'fa7a35',

      'fae500',

      '22A45D',

      '0080ff',

      '000080',

      'a020f0',

      'fccacb',

      'fdbf0f',

      'fffca1',

      'cafca6',

      'a6fcce',

      'a6f4fc',

      'a6d8fc',

      'a6c0fc',

      'a6affc',

      'dda6fc',

      'fca6ca',
    ];
    await firestoreService.addDefaultColors(defaultColors);
  }

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoSans',
      ),
      home: HomeScreen(),
    ),
  );
}

import 'package:class_calendar/const/colors.dart';
import 'package:class_calendar/model/schedule.dart';
import 'package:class_calendar/services/firestore_service.dart';
import 'package:flutter/material.dart';

class TodayBanner extends StatelessWidget {
  final DateTime selectedDay;
  final FirestoreService _firestoreService = FirestoreService();

  TodayBanner({
    required this.selectedDay,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    return Container(
      color: goodColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${selectedDay.year}년 ${selectedDay.month}월 ${selectedDay.day}일',
              style: textStyle,
            ),
            StreamBuilder<List<Schedule>>(
                stream: _firestoreService.watchSchedules(selectedDay),
                builder: (context, snapshot) {
                  int count = 0;

                  if (snapshot.hasData) {
                    count = snapshot.data!.length;
                  }

                  return Text(
                    '$count개',
                    style: textStyle,
                  );
                }),
          ],
        ),
      ),
    );
  }
}
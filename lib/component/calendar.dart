import 'package:class_calendar/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatelessWidget{
  final DateTime? selectedDay;
  final DateTime focusedDay;
  final OnDaySelected? onDaySelected;

  final List<dynamic> Function(DateTime day)? eventLoader;

  const Calendar({
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    this.eventLoader,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultBoxDeco = BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      border: Border.all(
        color: Colors.transparent,
        width: 1.0,
      ),
    );

    final defaultTextStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: 16.0,
      fontWeight: FontWeight.w700,
    );

    return TableCalendar(
      locale: 'ko_KR',
      focusedDay: focusedDay,
      firstDay: DateTime(1800),
      lastDay: DateTime(3000),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 17.0,
        ),
      ),
      calendarStyle: CalendarStyle(
        isTodayHighlighted: true,
        defaultDecoration: defaultBoxDeco,
        weekendDecoration: defaultBoxDeco,
        selectedDecoration: defaultBoxDeco.copyWith(
          color: goodColor,
          border: Border.all(
            color: goodColor,
            width: 2.0,
          )
        ),
        todayDecoration: defaultBoxDeco.copyWith(
          border: Border.all(
            color: goodColor,
            width: 2.0,
          )
        ),
        outsideDecoration: defaultBoxDeco,
        todayTextStyle: defaultTextStyle.copyWith(fontSize: 15.0, color: Colors.black),
        defaultTextStyle: defaultTextStyle,
        selectedTextStyle: defaultTextStyle.copyWith(color: Colors.white, fontSize: 16.0),
        weekendTextStyle: defaultTextStyle.copyWith(color: Colors.red),
      ),

      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isNotEmpty) {
            // 이 위젯이 새로운 점의 모양을 결정합니다.
            return Positioned(
              right: 2,  // 오른쪽에서의 거리
              bottom: 37, // 아래쪽에서의 거리
              child: Container(
                width: 15.0,   // 점의 너비
                height: 15.0,  // 점의 높이
                decoration: BoxDecoration(
                  color: Color(0xfff64c15), // 👈 여기서 점의 색상을 바꿀 수 있습니다.
                  shape: BoxShape.circle,
                ),

                child: Center(
                  child: Text(
                    '${events.length}', // 스케줄 개수
                    style: TextStyle(
                      color: Colors.white, // 숫자 색상
                      fontSize: 10.0,      // 숫자 폰트 크기
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }
          return null; // 이벤트가 없으면 아무것도 표시하지 않음
        },

        defaultBuilder: (context, day, focusedDay) {
          Color textColor;
          if (day.weekday == DateTime.saturday) {
            textColor = Colors.blue[700]!;
          } else if (day.weekday == DateTime.sunday) {
            textColor = Colors.red[700]!;
          } else {
            textColor = Colors.grey[600]!;
          }
          final events = eventLoader?.call(day) ?? [];
          if (events.isNotEmpty) {
            return Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                // width: double.infinity,
                // height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Color(0xff459df3).withOpacity(0.2),
                  //color: Color(0xffc92519).withOpacity(0.2),
                  shape: BoxShape.rectangle,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            );
          } else {
            return Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                    color: textColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700),
              ),
            );
          }
        },
      ),

      eventLoader: eventLoader,
      onDaySelected: onDaySelected,
      selectedDayPredicate: (DateTime date) {
        if (selectedDay == null) {
          return false;
        }

        return date.year == selectedDay!.year &&
            date.month == selectedDay!.month &&
            date.day == selectedDay!.day;
      },
    );
  }
}

import 'package:class_calendar/component/calendar.dart';
import 'package:class_calendar/component/schedule_bottom_sheet.dart';
import 'package:class_calendar/component/schedule_card.dart';
import 'package:class_calendar/component/today_banner.dart';
import 'package:class_calendar/const/colors.dart';
import 'package:class_calendar/model/schedule.dart';
import 'package:class_calendar/services/firestore_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDay = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: renderFloatingActionButton(),
      body: SafeArea(
        child: StreamBuilder<List<Schedule>>(
          stream: _firestoreService.watchAllSchedules(),
          builder: (context, snapshot) {
            Map<DateTime, List<Schedule>> events = {};
            if (snapshot.hasData) {
              for (final schedule in snapshot.data!) {
                final dateKey = DateTime.utc(
                    schedule.date.year, schedule.date.month, schedule.date.day);
                if (events[dateKey] == null) {
                  events[dateKey] = [];
                }
                events[dateKey]!.add(schedule);
              }
            }

            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Column(
                    children: [
                      Text(
                        '형석고 3학년 1반 학급 공용 캘린더',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Made by 일일일정',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: grColor,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ],
                  ),
                ),
                Calendar(
                  selectedDay: selectedDay,
                  focusedDay: focusedDay,
                  onDaySelected: onDaySelected,
                  eventLoader: (day) {
                    final normalizedDay =
                    DateTime.utc(day.year, day.month, day.day);
                    return events[normalizedDay] ?? [];
                  },
                ),
                const SizedBox(height: 8.0),
                TodayBanner(
                  selectedDay: selectedDay,
                ),
                const SizedBox(height: 8.0),
                _ScheduleList(
                  selectedDate: selectedDay,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  FloatingActionButton renderFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) {
            return ScheduleBottomSheet(
              selectedDate: selectedDay,
            );
          },
        );
      },
      backgroundColor: goodColor,
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      this.selectedDay = selectedDay;
      this.focusedDay = selectedDay;
    });
  }
}

class _ScheduleList extends StatelessWidget {
  final DateTime selectedDate;
  final FirestoreService _firestoreService = FirestoreService();

  _ScheduleList({required this.selectedDate, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8),
        child: StreamBuilder<List<Schedule>>(
          stream: _firestoreService.watchSchedules(selectedDate),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('오류가 발생했습니다.'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('스케줄이 없습니다.'),
              );
            }

            return ListView.separated(
              itemCount: snapshot.data!.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 8.0);
              },
              itemBuilder: (context, index) {
                final schedule = snapshot.data![index];

                return Dismissible(
                  key: ObjectKey(schedule.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (DismissDirection direction) {
                    _firestoreService.deleteSchedule(schedule.id);
                  },
                  confirmDismiss: (DismissDirection direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          title: const Text("삭제 확인"),
                          content: const Text("이 스케줄을 정말로 삭제하시겠습니까?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("취소", style: TextStyle(color: grColor),),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("삭제", style: TextStyle(color: Color(0xffff0033))),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  background: Container(
                    decoration: BoxDecoration(
                      color: Color(0xffff0033),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Icon(Icons.delete, color: Colors.white),
                        // SizedBox(width: 8),
                      ],
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) {
                          return ScheduleBottomSheet(
                            selectedDate: selectedDate,
                            scheduleId: schedule.id,
                          );
                        },
                      );
                    },
                    child: ScheduleCard(
                      startTime: schedule.startTime,
                      endTime: schedule.endTime,
                      content: schedule.content,
                      color: Color(
                        int.parse('FF${schedule.colorHexCode}', radix: 16),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
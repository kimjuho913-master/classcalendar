import 'package:class_calendar/const/colors.dart';
import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  // 24h
  // 13:00
  final int startTime;
  final int endTime;
  final String content;
  final Color color;

  const ScheduleCard({
    required this.startTime,
    required this.endTime,
    required this.content,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(50),
          right: Radius.circular(50),
        ),
        border: Border.all(
          width: 2.0,
          color: color,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Time(
                startTime: startTime,
                endTime: endTime,
                color: color,
              ),
              SizedBox(width: 10.0),
              Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(50.0),
                    bottom: Radius.circular(50.0),
                  ),
                ),
                width: 3.5,
              ),
              SizedBox(width: 10,),
              _Content(
                content: content,
              ),
              SizedBox(width: 16.0),
              _Category(
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Time extends StatelessWidget {
  final int startTime;
  final int endTime;
  final Color color;

  const _Time({
    required this.startTime,
    required this.endTime,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: color,
      fontSize: 16.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${startTime.toString().padLeft(2, '0')}:00부터',
          style: textStyle.copyWith(fontSize: 14.50),
        ),
        Text(
          '${endTime.toString().padLeft(2, '0')}:00까지',
          style: textStyle.copyWith(
            fontSize: 14.50,
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final String content;

  const _Content({
    required this.content,
    Key? key,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          content,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _Category extends StatelessWidget {
  final Color color;

  const _Category({
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      width: 16.0,
      height: 16.0,
    );
  }
}

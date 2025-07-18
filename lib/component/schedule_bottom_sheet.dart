import 'package:class_calendar/component/custom_text_field.dart';
import 'package:class_calendar/const/colors.dart';
import 'package:class_calendar/model/category_color.dart';
import 'package:class_calendar/model/schedule.dart';
import 'package:class_calendar/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 형식화를 위해 추가

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final String? scheduleId;

  const ScheduleBottomSheet({
    required this.selectedDate,
    this.scheduleId,
    Key? key,
  }) : super(key: key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final FirestoreService _firestoreService = FirestoreService();

  int? startTime;
  int? endTime;
  String? content;
  String? selectedColorHex;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: FutureBuilder<Schedule?>(
          future: widget.scheduleId == null
              ? null
              : _firestoreService.getScheduleById(widget.scheduleId!),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('스케줄을 불러올 수 없습니다.'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting &&
                widget.scheduleId != null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasData && startTime == null) {
              final schedule = snapshot.data!;
              startTime = schedule.startTime;
              endTime = schedule.endTime;
              content = schedule.content;
              selectedColorHex = schedule.colorHexCode;
            }

            return SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height / 2 + bottomInset,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: Padding(
                    padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Time(
                            onStartSaved: (String? val) =>
                            startTime = int.parse(val!),
                            onEndSaved: (String? val) =>
                            endTime = int.parse(val!),
                            startInitialValue: startTime?.toString() ?? '',
                            endInitialValue: endTime?.toString() ?? '',
                          ),
                          const SizedBox(height: 8.0),
                          _Content(
                            onSaved: (String? val) => content = val,
                            initialValue: content ?? '',
                          ),
                          const SizedBox(height: 8.0),
                          FutureBuilder<List<CategoryColor>>(
                              future: _firestoreService.getCategoryColors(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    selectedColorHex == null &&
                                    snapshot.data!.isNotEmpty) {
                                  selectedColorHex = snapshot.data![0].hexCode;
                                }

                                return _ColorPicker(
                                  colors:
                                  snapshot.hasData ? snapshot.data! : [],
                                  selectedColorHex: selectedColorHex,
                                  colorHexSetter: (String hexCode) {
                                    setState(() {
                                      selectedColorHex = hexCode;
                                    });
                                  },
                                );
                              }),
                          const SizedBox(height: 8.0),
                          _SaveButton(
                            onPressed: onSavePressed,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  // (수정된 부분)
  void onSavePressed() async {
    // formKey의 유효성 검사를 통과하지 못하면 함수를 종료합니다.
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return;
    }

    // form의 상태를 저장합니다.
    formKey.currentState!.save();

    // 새 스케줄을 생성하는 경우 (scheduleId가 없을 때)
    if (widget.scheduleId == null) {
      // 캘린더에서 선택한 스케줄 날짜
      final scheduleDate = widget.selectedDate;
      // '저장' 버튼을 누른 현재 시각
      final createdAt = DateTime.now();

      // 1. 스케줄 날짜를 'YYYY-MM-DD' 형식의 문자열로 변환합니다.
      final scheduleDateString = DateFormat('yyyy-MM-dd').format(scheduleDate);

      // 2. 생성 시점을 ISO 8601 형식의 문자열로 변환합니다.
      // (예: 2025-07-16T21:10:30.123456)
      final createdAtString = createdAt.toIso8601String();

      // 3. 두 문자열을 '_'로 조합하여 최종 문서 ID를 생성합니다.
      final customId = '${scheduleDateString}_$createdAtString';

      final newSchedule = Schedule(
        id: customId, // 직접 생성한 ID를 사용합니다.
        content: content!,
        date: scheduleDate,
        startTime: startTime!,
        endTime: endTime!,
        colorHexCode: selectedColorHex!,
        createdAt: createdAt.toUtc(), // Firestore에는 UTC 기준으로 저장합니다.
      );
      // Firestore 서비스로 스케줄을 추가합니다.
      await _firestoreService.addSchedule(newSchedule);
    } else {
      // 기존 스케줄을 수정하는 경우
      final updatedSchedule = Schedule(
        id: widget.scheduleId!,
        content: content!,
        date: widget.selectedDate,
        startTime: startTime!,
        endTime: endTime!,
        colorHexCode: selectedColorHex!,
        createdAt: DateTime.now().toUtc(), // 수정한 시각으로 업데이트
      );
      // Firestore에서 스케줄을 업데이트합니다.
      await _firestoreService.updateSchedule(updatedSchedule);
    }

    // 작업 완료 후, 현재 화면(BottomSheet)을 닫습니다.
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _Time extends StatelessWidget {
  final FormFieldSetter<String> onStartSaved;
  final FormFieldSetter<String> onEndSaved;
  final String startInitialValue;
  final String endInitialValue;

  const _Time({
    required this.onStartSaved,
    required this.onEndSaved,
    required this.startInitialValue,
    required this.endInitialValue,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            label: '시작 시간',
            isTime: true,
            onSaved: onStartSaved,
            initialValue: startInitialValue,
            hintText: '24시법 예: 21',
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: CustomTextField(
            label: '마감 시간',
            isTime: true,
            onSaved: onEndSaved,
            initialValue: endInitialValue,
            hintText: '24시법 예: 22',
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final FormFieldSetter<String> onSaved;
  final String initialValue;

  const _Content({
    required this.onSaved,
    required this.initialValue,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomTextField(
        label: '내용',
        isTime: false,
        onSaved: onSaved,
        initialValue: initialValue,
        hintText: '일정 내용을 입력해주세요!',
      ),
    );
  }
}

typedef ColorHexSetter = void Function(String hexCode);

class _ColorPicker extends StatelessWidget {
  final List<CategoryColor> colors;
  final String? selectedColorHex;
  final ColorHexSetter colorHexSetter;

  const _ColorPicker({
    required this.colors,
    required this.selectedColorHex,
    required this.colorHexSetter,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: colors
            .map(
              (e) => GestureDetector(
            onTap: () {
              colorHexSetter(e.hexCode);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: renderColor(
                e,
                selectedColorHex == e.hexCode,
              ),
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget renderColor(CategoryColor color, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(
          int.parse(
            'FF${color.hexCode}',
            radix: 16,
          ),
        ),
        border: isSelected
            ? Border.all(
          color: Colors.black,
          width: 4.0,
        )
            : null,
      ),
      width: 32.0,
      height: 32.0,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveButton({
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: goodColor,
            ),
            child: const Text(
              '저장',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
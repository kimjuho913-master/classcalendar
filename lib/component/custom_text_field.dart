import 'package:class_calendar/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String initialValue;
  final String? hintText;

  // true - 시간 / false - 내용
  final bool isTime;
  final FormFieldSetter<String> onSaved;

  const CustomTextField({
    required this.isTime,
    required this.label,
    required this.onSaved,
    required this.initialValue,
    this.hintText,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            label,
            style: TextStyle(
              color: goodColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (isTime) renderTextField(),
        if (!isTime)
          Expanded(
            child: renderTextField(),
          ),
      ],
    );
  }

  Widget renderTextField() {
    return TextFormField(
      onSaved: onSaved,
      // null이 return 되면 에러가 없다.
      // 에러가 있으면 에러를 String 값으로 리턴해준다.
      validator: (String? val){
        if(val == null || val.isEmpty){
          return '값을 입력해주세요';
        }

        if(isTime){
          int time = int.parse(val);

          if(time < 0){
            return '0 이상의 숫자를 입력해주세요';
          }

          if(time > 24){
            return '24 이하의 숫자를 입력해주세요';
          }
        }else{
          if(val.length > 500){
            return '500자 이하의 글자를 입력해주세요.';
          }
        }

        return null;
      },
      cursorColor: Colors.grey,
      maxLines: isTime ? 1 : null,
      expands: !isTime,
      initialValue: initialValue,
      textAlign: TextAlign.center,
      textAlignVertical: TextAlignVertical.center,
      keyboardType: isTime ? TextInputType.number : TextInputType.multiline,
      inputFormatters: isTime
          ? [
              FilteringTextInputFormatter.digitsOnly,
            ]
          : [],
      decoration: InputDecoration(
        border: OutlineInputBorder( // 테두리를 둥글게 설정
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            width: 0,
            style: BorderStyle.none, // 테두리 선 없애기
          ),
        ),
        filled: true,
        fillColor: Colors.grey[300],
        suffixText: isTime ? '시' : null,
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        )
      ),
    );
  }
}
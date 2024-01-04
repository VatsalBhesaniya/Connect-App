import 'package:connect/utils/text_styles.dart';
import 'package:flutter/material.dart';

class TextWidget {
  Text latoTextWidget({
    required String text,
    TextAlign? textAlign,
    Color? color,
    FontStyle? fontStyle,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyles().latoTextStyle(
        color: color,
        fontStyle: fontStyle,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
      ),
    );
  }

  Text workSansTextWidget({
    required String text,
    TextAlign? textAlign,
    Color? color,
    FontStyle? fontStyle,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyles().workSansTextStyle(
        color: color,
        fontStyle: fontStyle,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
      ),
    );
  }

  Text varelaRoundTextWidget({
    required String text,
    TextAlign? textAlign,
    Color? color,
    FontStyle? fontStyle,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyles().varelaRoundTextStyle(
        color: color,
        fontStyle: fontStyle,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
      ),
    );
  }
}

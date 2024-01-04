import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextStyles {
  TextStyle latoTextStyle({
    Color? color,
    FontStyle? fontStyle,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
  }) {
    return GoogleFonts.lato(
      color: color,
      fontStyle: fontStyle,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
    );
  }

  TextStyle workSansTextStyle({
    Color? color,
    FontStyle? fontStyle,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
  }) {
    return GoogleFonts.workSans(
      color: color,
      fontStyle: fontStyle,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
    );
  }

  TextStyle varelaRoundTextStyle({
    Color? color,
    FontStyle? fontStyle,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
  }) {
    return GoogleFonts.varelaRound(
      color: color,
      fontStyle: fontStyle,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
    );
  }
}

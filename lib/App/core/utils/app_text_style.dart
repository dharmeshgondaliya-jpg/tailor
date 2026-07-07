import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyle {
  static TextStyle regularBlack({double? fontSize, TextOverflow? overflow, Color? color}) {
    return GoogleFonts.poppins(
      color: color ?? Colors.black,
      fontWeight: FontWeight.w400,
      fontSize: fontSize,
    ).copyWith(overflow: overflow);
  }

  static TextStyle mediumBlack({double? fontSize, TextOverflow? overflow, Color? color}) {
    return GoogleFonts.poppins(
      color: color ?? Colors.black,
      fontWeight: FontWeight.w500,
      fontSize: fontSize,
    ).copyWith(overflow: overflow);
  }

  static TextStyle semiBoldBlack({double? fontSize, TextOverflow? overflow, Color? color}) {
    return GoogleFonts.poppins(
      color: color ?? Colors.black,
      fontWeight: FontWeight.w600,
      fontSize: fontSize,
    ).copyWith(overflow: overflow);
  }

  static TextStyle boldBlack({double? fontSize, TextOverflow? overflow, Color? color}) {
    return GoogleFonts.poppins(
      color: color ?? Colors.black,
      fontWeight: FontWeight.w700,
      fontSize: fontSize,
    ).copyWith(overflow: overflow);
  }

  /// Grey label text — for secondary/helper text
  static TextStyle labelGrey({double? fontSize}) {
    return GoogleFonts.poppins(
      color: const Color(0xFF9CA3AF),
      fontWeight: FontWeight.w400,
      fontSize: fontSize ?? 12,
    );
  }

  /// Caption text — for smallest descriptive text
  static TextStyle captionBlack({double? fontSize}) {
    return GoogleFonts.poppins(
      color: const Color(0xFF6B7280),
      fontWeight: FontWeight.w400,
      fontSize: fontSize ?? 11,
    );
  }
}

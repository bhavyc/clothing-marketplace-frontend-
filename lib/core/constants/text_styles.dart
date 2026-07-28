import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  // Luxury Serif Headings (Playfair Display)
  static TextStyle serifHeading1({Color color = AppColors.charcoal}) => 
      GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle serifHeading2({Color color = AppColors.charcoal}) => 
      GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle serifHeading3({Color color = AppColors.charcoal}) => 
      GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle serifBody({Color color = AppColors.charcoal, double fontSize = 14}) => 
      GoogleFonts.playfairDisplay(
        fontSize: fontSize,
        color: color,
      );

  // Modern Sans-serif text (Inter)
  static TextStyle sansBody({Color color = AppColors.charcoal, double fontSize = 14, FontWeight fontWeight = FontWeight.normal}) => 
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  static TextStyle sansSubtitle({Color color = AppColors.stone}) => 
      GoogleFonts.inter(
        fontSize: 12,
        color: color,
      );

  static TextStyle uppercaseLabel({Color color = AppColors.gold, double fontSize = 11, double letterSpacing = 1.5, FontWeight fontWeight = FontWeight.bold}) => 
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );
}

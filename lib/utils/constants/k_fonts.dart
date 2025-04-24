import 'package:flutter/material.dart';
import 'package:time_log/utils/constants/k_colors.dart';

class KFonts {
  KFonts._(); // Private constructor to prevent instantiation

  static const String poppins = "Poppins"; // Define font family

  static  const TextStyle heading = TextStyle(
    fontFamily: poppins,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: KColors.textHeadingColor,
  );

  static const TextStyle body = TextStyle(
    fontFamily: poppins,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: KColors.textColorGray,
  );
  static const TextStyle normalBold = TextStyle(
    fontFamily: poppins,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: KColors.textHeadingColor,
  );
  static const TextStyle normalBoldWithOrange = TextStyle(
    fontFamily: poppins,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: KColors.textHeadingColor,
  );
  static const TextStyle normalBoldWithGray = TextStyle(
    fontFamily: poppins,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: KColors.textColor,
  );
  static const TextStyle normalBoldWithWhite = TextStyle(
    fontFamily: poppins,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: KColors.appColorWhite,
  );

  static const TextStyle profileTextBold = TextStyle(
    fontFamily: poppins,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: KColors.appBlackColor,
  );
  static const TextStyle profileTextNormal = TextStyle(
    fontFamily: poppins,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: KColors.appBlackColor,
    letterSpacing: 0.12,
  );


  static const TextStyle normalBoldWithBlueColor = TextStyle(
    fontFamily: poppins,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: KColors.appPrimary,
    letterSpacing: 0.12,
  );
  static const TextStyle normalHeading = TextStyle(
    fontFamily: poppins,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: KColors.textHeadingColor,
    letterSpacing: 0.12,
  );
  static const TextStyle normal = TextStyle(
    fontFamily: poppins,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: KColors.textColorGray,
    letterSpacing: 0.12,
  );
  static const TextStyle normalWithGray = TextStyle(
    fontFamily: poppins,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: KColors.textColorGray,
    letterSpacing: 0.12,
  );
  static const TextStyle normalWithWithText = TextStyle(
    fontFamily: poppins,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: KColors.appColorWhite,
    letterSpacing: 0.12,
  );
  static const TextStyle thin = TextStyle(
    fontFamily: poppins,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: KColors.textColorGray,
    letterSpacing: 0.12,
  );
  static const TextStyle thinWithWhite = TextStyle(
    fontFamily: poppins,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: KColors.appColorWhite,
    letterSpacing: 0.12,
  );
  static const TextStyle boldForDay = TextStyle(
    fontFamily: poppins,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: KColors.textColorGray,
  );

  static const TextStyle button = TextStyle(
    fontFamily: poppins,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}

import 'package:flutter/material.dart';

///General Colors
const Color primaryColor = Color(0xff5781EB);
const Color secondaryColor = Color(0xff7D58EC);
const Color warningColor = Color(0xffcc3300);

const Color primaryShade = Color(0xff3566E2);
const Color secondaryShade = Color(0xff6136E3);

LinearGradient primaryGradient = const LinearGradient(
  colors: [primaryColor, primaryShade],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

LinearGradient greyGradient = LinearGradient(
  colors: [Colors.grey.withOpacity(.8), Colors.grey.withOpacity(.5)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

LinearGradient secondaryGradient = const LinearGradient(
  colors: [secondaryColor, secondaryShade],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

LinearGradient disableGradient = LinearGradient(
  colors: [Colors.grey.withOpacity(0.9), Colors.grey],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

LinearGradient primarySecondaryGradient = const LinearGradient(
  colors: [primaryColor, primaryShade, secondaryShade, secondaryColor],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

///Light Theme
const Color backgroundLight = Color(0xff0D1543);
const Color surfaceLight = Color(0xff202960);

///Dark theme
const Color backgroundDark = Color(0xff0D1543);
const Color surfaceDark = Color(0xff1f2d5e);

Color get shadowColor => Colors.black.withOpacity(.05);

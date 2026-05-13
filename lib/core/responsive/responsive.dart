import 'package:flutter/material.dart';

import 'breakpoints.dart';

class Responsive {
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static bool isMobile(BuildContext context) =>
      width(context) < Breakpoints.mobile;

  static bool isTablet(BuildContext context) =>
      width(context) >= Breakpoints.mobile &&
      width(context) < Breakpoints.tablet;

  static bool isDesktop(BuildContext context) =>
      width(context) >= Breakpoints.tablet;

  static bool isSmallMobile(BuildContext context) => width(context) < 360;

  static bool isSmallHeight(BuildContext context) => height(context) < 750;

  static bool isLargeDesktop(BuildContext context) =>
      width(context) >= Breakpoints.desktop;
}

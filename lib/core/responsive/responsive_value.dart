import 'package:flutter/material.dart';

import 'responsive.dart';

class ResponsiveValue {
  static double padding(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return 32;
    }

    if (Responsive.isTablet(context)) {
      return 24;
    }

    return 16;
  }

  static double radius(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return 20;
    }

    return 14;
  }
}

import 'package:flutter/material.dart';

import 'responsive.dart';

class ResponsiveText {
  static double headline(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return 32;
    }

    if (Responsive.isTablet(context)) {
      return 28;
    }

    return 22;
  }

  static double body(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return 18;
    }

    return 14;
  }
}

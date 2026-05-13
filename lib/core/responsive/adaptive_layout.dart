import 'package:flutter/material.dart';

import 'breakpoints.dart';

class AdaptiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const AdaptiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= Breakpoints.tablet) {
      return desktop ?? tablet ?? mobile;
    }

    if (width >= Breakpoints.mobile) {
      return tablet ?? mobile;
    }

    return mobile;
  }
}

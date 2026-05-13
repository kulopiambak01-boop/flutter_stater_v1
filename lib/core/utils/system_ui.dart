import 'package:flutter/services.dart';

class SystemUi {
  static void setStyle({
    required Color statusBarColor,
    required Color navigationBarColor,
    Brightness statusBarIconBrightness = Brightness.dark,
    Brightness navigationBarIconBrightness = Brightness.dark,
  }) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: statusBarColor,

        statusBarIconBrightness: statusBarIconBrightness,

        systemNavigationBarColor: navigationBarColor,

        systemNavigationBarIconBrightness: navigationBarIconBrightness,

        systemNavigationBarDividerColor: navigationBarColor,
      ),
    );
  }

  static void enableFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  static void disableFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}

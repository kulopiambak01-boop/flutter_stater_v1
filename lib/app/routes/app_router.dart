import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/navigation/presentation/pages/main_navigation_page.dart';
import '../../features/obd_scanner/presentation/pages/obd_scanner_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,

    routes: [
      GoRoute(
        path: AppRoutes.splash,

        builder: (context, state) {
          return const SplashPage();
        },
      ),

      GoRoute(
        path: AppRoutes.login,

        builder: (context, state) {
          return const LoginPage();
        },
      ),

      GoRoute(
        path: AppRoutes.home,

        builder: (context, state) {
          return const MainNavigationPage();
        },
      ),
      GoRoute(
        path: AppRoutes.obdScanner,

        builder: (context, state) {
          return const ObdScannerPage();
        },
      ),
    ],
  );
});

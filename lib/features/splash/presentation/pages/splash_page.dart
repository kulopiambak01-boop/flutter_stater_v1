import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/services/secure_storage.dart';
import '../../../../core/utils/system_ui.dart';
import '../widgets/splash_brand.dart';
import '../widgets/splash_loading.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  Future<void> _initialize() async {
    /// Fullscreen splash
    SystemUi.enableFullscreen();

    try {
      /// Simulasi loading branding
      await Future.delayed(const Duration(seconds: 5));

      final isLoggedIn = await SecureStorage.isLoggedIn();

      if (!mounted) return;

      if (isLoggedIn) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.login);
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,

          content: Text(error.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),

        child: SizedBox.expand(
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(),

                const SplashBrand(),

                const SizedBox(height: 56),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),

                  child: _isLoading
                      ? const SplashLoading()
                      : const SizedBox.shrink(),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(bottom: 24),

                  child: Column(
                    children: [
                      Text(
                        'Version 1.0.0',

                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),

                          fontSize: 12,

                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Powered by AksaraDev',

                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),

                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

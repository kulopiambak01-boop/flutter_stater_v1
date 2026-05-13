import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/responsive/adaptive_layout.dart';
import '../../../../core/responsive/responsive_value.dart';

import '../../../../core/utils/system_ui.dart';
import '../widgets/login_banner.dart';
import '../widgets/login_form.dart';
import '../widgets/login_footer.dart';
// import '../widgets/login_header.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemUi.disableFullscreen();
    SystemUi.setStyle(
      statusBarColor: Colors.transparent,

      navigationBarColor: AppColors.background,

      statusBarIconBrightness: Brightness.dark,

      navigationBarIconBrightness: Brightness.dark,
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: AdaptiveLayout(
          mobile: _mobile(context),
          tablet: _tablet(context),
          desktop: _desktop(context),
        ),
      ),
    );
  }

  Widget _mobile(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final padding = ResponsiveValue.padding(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        children: [
          // SizedBox(height: height * 0.03),
          // const LoginHeader(),
          SizedBox(height: height * 0.02),
          const LoginBanner(),
          SizedBox(height: height * 0.04),
          const LoginForm(),
          const SizedBox(height: 24),
          const LoginFooter(),
          SizedBox(height: height * 0.03),
        ],
      ),
    );
  }

  Widget _tablet(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 900),
            padding: const EdgeInsets.all(40),
            child: const Row(
              children: [
                Expanded(child: LoginBanner()),
                SizedBox(width: 40),
                Expanded(child: LoginForm()),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: LoginFooter(),
          ),
        ],
      ),
    );
  }

  Widget _desktop(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 1300),
            padding: const EdgeInsets.all(60),
            child: const Row(
              children: [
                Expanded(flex: 6, child: LoginBanner()),
                SizedBox(width: 60),
                Expanded(flex: 4, child: LoginForm()),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: LoginFooter(),
          ),
        ],
      ),
    );
  }
}

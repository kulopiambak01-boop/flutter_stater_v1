import 'package:flutter/material.dart';
import 'package:flutter_starter/features/obd_scanner/presentation/pages/obd_scanner_page.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/system_ui.dart';
import '../../../home/presentation/pages/home_page.dart';
import 'app_bottom_navigation.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int currentIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    SystemUi.disableFullscreen();
    SystemUi.setStyle(
      statusBarColor: Colors.transparent,

      navigationBarColor: AppColors.background,

      statusBarIconBrightness: Brightness.dark,

      navigationBarIconBrightness: Brightness.dark,
    );

    pages = const [
      HomePage(),

      _PlaceholderPage(title: 'Vehicle Monitor'),

      ObdScannerPage(),

      _PlaceholderPage(title: 'Service History'),

      _PlaceholderPage(title: 'Profile'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: pages[currentIndex],
      ),

      bottomNavigationBar: AppBottomNavigation(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,

        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }
}

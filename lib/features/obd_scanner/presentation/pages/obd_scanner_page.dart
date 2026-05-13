import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/responsive.dart';
import '../controllers/obd_scanner_controller.dart';
import '../sections/obd_dashboard_section.dart';
import '../sections/obd_device_section.dart';
import '../sections/obd_live_section.dart';
import '../widgets/obd_debug_overlay.dart';

class ObdScannerPage extends ConsumerStatefulWidget {
  const ObdScannerPage({super.key});

  @override
  ConsumerState<ObdScannerPage> createState() => _ObdScannerPageState();
}

class _ObdScannerPageState extends ConsumerState<ObdScannerPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialScan();
    });
  }

  Future<void> _initialScan() async {
    await ref.read(obdScannerControllerProvider.notifier).scan();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final padding = isMobile ? 16.0 : 28.0;

    // 🔥 WRAP WITH DEBUG OVERLAY
    return ObdDebugOverlay(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _initialScan,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverAppBar(
                  pinned: true,
                  floating: true,
                  snap: true,
                  elevation: 0,
                  expandedHeight: 80,
                  backgroundColor: Colors.white,
                  title: ObdDashboardSection(),
                ),
                SliverPadding(
                  padding: EdgeInsets.all(padding),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const ObdLiveSection(),
                      SizedBox(height: padding),
                      const ObdDeviceSection(),
                      const SizedBox(height: 120),
                    ]),
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

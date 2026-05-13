import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/responsive/adaptive_layout.dart';
import '../../../../core/responsive/responsive_value.dart';

import '../widgets/dashboard_card.dart';
import '../widgets/education_item.dart';
import '../widgets/quick_action_item.dart';
import '../widgets/quick_insight_item.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final padding = ResponsiveValue.padding(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: AdaptiveLayout(
          mobile: _mobile(context, ref, padding, themeMode),
          tablet: Center(
            child: SizedBox(
              width: 700,
              child: _mobile(context, ref, padding, themeMode),
            ),
          ),
          desktop: Center(
            child: SizedBox(
              width: 900,
              child: _mobile(context, ref, padding, themeMode),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mobile(
    BuildContext context,
    WidgetRef ref,
    double padding,
    ThemeMode themeMode,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, ref, themeMode),
          const SizedBox(height: 28),
          const DashboardCard(),
          const SizedBox(height: 28),
          Text('Quick Insights', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: QuickInsightItem(
                  title: 'ENGINE',
                  value: '--',
                  icon: Icons.thermostat,
                  color: Color(0xFFFFF3E8),
                  iconColor: Colors.orange,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: QuickInsightItem(
                  title: 'BATTERY',
                  value: '--',
                  icon: Icons.battery_4_bar,
                  color: Color(0xFFF0F4FF),
                  iconColor: Colors.blue,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: QuickInsightItem(
                  title: 'FUEL',
                  value: '--',
                  icon: Icons.local_gas_station,
                  color: Color(0xFFEFFAF4),
                  iconColor: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _serviceReminder(context),
          const SizedBox(height: 28),
          Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 18),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.2,
            children: const [
              QuickActionItem(
                title: 'Scan Kendaraan',
                icon: Icons.search,
                color: Color(0xFF6C63FF),
              ),
              QuickActionItem(
                title: 'Catat Servis',
                icon: Icons.add,
                color: Color(0xFF00C48C),
              ),
              QuickActionItem(
                title: 'Cari Bengkel',
                icon: Icons.location_on,
                color: Color(0xFFFF3B6B),
              ),
              QuickActionItem(
                title: 'Connect OBD',
                icon: Icons.bluetooth,
                color: Color(0xFF1DA1F2),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edukasi Pintar',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Lihat Semua',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const EducationItem(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, WidgetRef ref, ThemeMode themeMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, pengguna',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Aksara',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
          ),
          tooltip: 'Ganti tema',
          onPressed: () {
            ref.read(themeModeProvider.notifier).toggleThemeMode();
          },
        ),
      ],
    );
  }

  Widget _serviceReminder(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.bolt, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ganti oli dalam 5 hari',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Jadwal servis rutin berikutnya',
                  style: TextStyle(color: Colors.orange, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.orange),
        ],
      ),
    );
  }
}

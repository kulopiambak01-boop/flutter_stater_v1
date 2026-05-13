import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/obd/models/obd_live_data.dart';
import '../../../../core/obd/providers/obd_provider.dart';

import '../../../../core/responsive/responsive.dart';

import '../widgets/obd_live_card.dart';

class ObdLiveSection extends ConsumerWidget {
  const ObdLiveSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveState = ref.watch(obdLiveDataControllerProvider);

    final width = MediaQuery.of(context).size.width;

    final isTablet = Responsive.isTablet(context);

    final gridCount = width > 1300
        ? 4
        : width > 900
        ? 3
        : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        _buildHeader(context),

        const SizedBox(height: 18),

        liveState.when(
          data: (data) {
            return _buildGrid(
              data: data,
              gridCount: gridCount,
              isTablet: isTablet,
            );
          },

          loading: () => const _LoadingState(),

          error: (e, _) => _ErrorState(message: e.toString()),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.analytics_rounded),

        const SizedBox(width: 10),

        Text(
          'Live Vehicle Telemetry',

          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildGrid({
    required ObdLiveData data,
    required int gridCount,
    required bool isTablet,
  }) {
    return GridView.count(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      crossAxisCount: gridCount,

      crossAxisSpacing: 16,

      mainAxisSpacing: 16,

      childAspectRatio: isTablet ? 1.35 : 1.18,

      children: [
        ObdLiveCard(
          label: 'RPM',

          value: data.rpm.toStringAsFixed(0),

          icon: Icons.speed,
        ),

        ObdLiveCard(
          label: 'Speed',

          value: '${data.speed.toStringAsFixed(0)} km/h',

          icon: Icons.route,
        ),

        ObdLiveCard(
          label: 'Coolant',

          value: '${data.coolantTemp.toStringAsFixed(0)}°C',

          icon: Icons.thermostat_rounded,
        ),

        ObdLiveCard(
          label: 'Battery',

          value: '${data.batteryVoltage.toStringAsFixed(1)} V',

          icon: Icons.battery_5_bar,
        ),

        ObdLiveCard(
          label: 'Engine Load',

          value: '${data.engineLoad.toStringAsFixed(0)}%',

          icon: Icons.settings,
        ),

        ObdLiveCard(
          label: 'Fuel',

          value: '${data.fuelLevel.toStringAsFixed(0)}%',

          icon: Icons.local_gas_station,
        ),

        /// =========================
        /// NEW TELEMETRY
        /// =========================
        ObdLiveCard(
          label: 'MAF',

          value: '${data.maf.toStringAsFixed(1)} g/s',

          icon: Icons.air,
        ),

        ObdLiveCard(
          label: 'Trip',

          value: '${data.tripKm.toStringAsFixed(2)} km',

          icon: Icons.alt_route,
        ),

        ObdLiveCard(
          label: 'Fuel Used',

          value: '${data.fuelUsedL.toStringAsFixed(2)} L',

          icon: Icons.local_gas_station_outlined,
        ),

        ObdLiveCard(
          label: 'AVG',

          value: '${data.avgKmL.toStringAsFixed(1)} km/L',

          icon: Icons.analytics_rounded,
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(30),

      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),

      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),

          borderRadius: BorderRadius.circular(20),
        ),

        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),

            const SizedBox(width: 12),

            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}

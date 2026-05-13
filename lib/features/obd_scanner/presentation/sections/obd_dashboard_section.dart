import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/obd/providers/obd_provider.dart';

class ObdDashboardSection extends ConsumerWidget {
  const ObdDashboardSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transport = ref.watch(activeObdTransportProvider);

    final connected = transport?.isConnected ?? false;

    return Row(
      children: [
        _buildLogo(),

        const SizedBox(width: 14),

        Expanded(child: _buildTitle(context)),

        _ConnectionBadge(connected: connected),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 42,
      height: 42,

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
        ),

        borderRadius: BorderRadius.circular(14),
      ),

      child: const Icon(Icons.memory_rounded, color: Colors.white),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      mainAxisSize: MainAxisSize.min,

      children: [
        const Text(
          'OBD Diagnostics',

          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),

        Text(
          'Realtime Vehicle Telemetry',

          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  final bool connected;

  const _ConnectionBadge({required this.connected});

  @override
  Widget build(BuildContext context) {
    final color = connected ? Colors.green : Colors.redAccent;

    final text = connected ? 'Connected' : 'Disconnected';

    final icon = connected ? Icons.check_circle : Icons.bluetooth_disabled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: color.withValues(alpha: 0.25)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),

            blurRadius: 10,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Icon(icon, size: 18, color: color),

          const SizedBox(width: 8),

          Text(
            text,

            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

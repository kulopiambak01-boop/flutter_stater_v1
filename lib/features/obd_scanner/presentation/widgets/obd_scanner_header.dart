import 'package:flutter/material.dart';

class ObdScannerHeader extends StatelessWidget {
  const ObdScannerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(28),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF06B6D4)],
        ),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),

                  borderRadius: BorderRadius.circular(22),

                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),

                child: const Icon(
                  Icons.bluetooth_searching_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),

                  borderRadius: BorderRadius.circular(30),
                ),

                child: const Row(
                  children: [
                    Icon(Icons.flash_on_rounded, size: 16, color: Colors.white),

                    SizedBox(width: 6),

                    Text(
                      'Realtime',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          Text(
            'Scanner OBD2',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Realtime automotive diagnostics, live telemetry, dan analisa kendaraan modern.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _FeatureChip(icon: Icons.bluetooth, label: 'Bluetooth'),
              _FeatureChip(icon: Icons.wifi, label: 'WiFi'),
              _FeatureChip(icon: Icons.memory, label: 'ELM327'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),

        borderRadius: BorderRadius.circular(30),

        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),

          const SizedBox(width: 8),

          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

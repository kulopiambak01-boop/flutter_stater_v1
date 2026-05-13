import 'package:flutter/material.dart';

class ObdEmptyState extends StatelessWidget {
  final VoidCallback? onRetry;

  const ObdEmptyState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: size.height * 0.08,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_disabled_rounded,
            size: 72,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 18),

          Text(
            'Perangkat OBD2 tidak ditemukan',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(
            'Pastikan OBD2 aktif, mode pairing ON, dan berada dalam jangkauan Bluetooth atau WiFi',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),

          const SizedBox(height: 24),

          if (onRetry != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,

                icon: const Icon(Icons.refresh),

                label: const Text(
                  'Retry Scan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

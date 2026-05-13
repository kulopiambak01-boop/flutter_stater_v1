import 'package:flutter/material.dart';

import '../../../../core/obd/models/obd_connection_type.dart';
import '../../../../core/obd/models/obd_device.dart';

class ObdDeviceTile extends StatelessWidget {
  final ObdDevice device;

  final VoidCallback? onTap;

  final bool loading;

  final bool connected;

  final bool disabled;

  const ObdDeviceTile({
    super.key,

    required this.device,

    this.onTap,

    this.loading = false,

    this.connected = false,

    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _color();

    return Opacity(
      opacity: disabled ? 0.55 : 1,

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          onTap: loading || disabled ? null : onTap,

          borderRadius: BorderRadius.circular(20),

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),

            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(20),

              border: Border.all(
                color: connected ? color : Colors.grey.shade200,

                width: connected ? 1.6 : 1,
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),

                  blurRadius: 14,

                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: Row(
              children: [
                _buildLeading(color),

                const SizedBox(width: 14),

                Expanded(child: _buildInfo(context)),

                _buildTrailing(color),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(Color color) {
    return Stack(
      alignment: Alignment.center,

      children: [
        Container(
          width: 52,
          height: 52,

          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),

            borderRadius: BorderRadius.circular(16),
          ),

          child: Icon(_icon(), color: color, size: 26),
        ),

        if (loading)
          const SizedBox(
            width: 54,
            height: 54,

            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                device.name,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  fontWeight: FontWeight.w700,

                  fontSize: 15,
                ),
              ),
            ),

            if (connected)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),

                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),

                  borderRadius: BorderRadius.circular(30),
                ),

                child: const Text(
                  'CONNECTED',

                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Icon(Icons.network_cell, size: 14, color: _rssiColor(device.rssi)),

            const SizedBox(width: 6),

            Text(
              '${device.rssi} dBm',

              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),

            const SizedBox(width: 10),

            Container(
              width: 5,
              height: 5,

              decoration: BoxDecoration(
                color: Colors.grey.shade400,

                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 10),

            Text(
              _typeLabel(),

              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          device.id,

          maxLines: 1,

          overflow: TextOverflow.ellipsis,

          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildTrailing(Color color) {
    if (loading) {
      return const SizedBox(
        width: 22,
        height: 22,

        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (connected) {
      return Icon(Icons.check_circle, color: color);
    }

    return Icon(
      Icons.arrow_forward_ios_rounded,

      size: 16,

      color: Colors.grey.shade500,
    );
  }

  IconData _icon() {
    switch (device.type) {
      case ObdConnectionType.bluetooth:
        return Icons.bluetooth_rounded;

      case ObdConnectionType.wifi:
        return Icons.wifi_rounded;
    }
  }

  Color _color() {
    switch (device.type) {
      case ObdConnectionType.bluetooth:
        return Colors.blue;

      case ObdConnectionType.wifi:
        return Colors.green;
    }
  }

  String _typeLabel() {
    switch (device.type) {
      case ObdConnectionType.bluetooth:
        return 'Bluetooth';

      case ObdConnectionType.wifi:
        return 'WiFi';
    }
  }

  Color _rssiColor(int rssi) {
    if (rssi >= -60) {
      return Colors.green;
    }

    if (rssi >= -80) {
      return Colors.orange;
    }

    return Colors.redAccent;
  }
}

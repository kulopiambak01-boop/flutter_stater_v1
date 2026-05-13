import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/obd/models/obd_device.dart';

import '../controllers/obd_scanner_controller.dart';

import '../widgets/obd_device_tile.dart';
import '../widgets/obd_empty_state.dart';

class ObdDeviceSection extends ConsumerWidget {
  const ObdDeviceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannerState = ref.watch(obdScannerControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        _buildHeader(context),

        const SizedBox(height: 18),

        scannerState.when(
          data: (devices) {
            return _DeviceList(devices: devices);
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                'Available Devices',

                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 6),

              Text(
                'Nearby OBD adapters ready to connect',

                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(18),

            border: Border.all(color: Colors.grey.shade200),
          ),

          child: Row(
            children: [
              const Icon(Icons.bluetooth, size: 18),

              const SizedBox(width: 8),

              Text(
                'Wireless',

                style: TextStyle(
                  fontWeight: FontWeight.w600,

                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeviceList extends ConsumerWidget {
  final List<ObdDevice> devices;

  const _DeviceList({required this.devices});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDevices = ref.watch(obdScannerControllerProvider);
    final controller = ref.read(obdScannerControllerProvider.notifier);

    return asyncDevices.when(
      data: (_) {
        if (devices.isEmpty) {
          return _buildEmpty(ref);
        }

        return Column(
          children: devices
              .map((device) => _buildItem(device, controller))
              .toList(),
        );
      },
      loading: () => const _LoadingState(),
      error: (e, _) => _ErrorState(message: e.toString()),
    );
  }

  Widget _buildItem(ObdDevice device, ObdScannerController controller) {
    final isLoading = controller.connectingDeviceId == device.id;
    final isConnected = controller.connectedDeviceId == device.id;

    final isDisabled =
        controller.connectingDeviceId != null &&
        controller.connectingDeviceId != device.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ObdDeviceTile(
        device: device,
        loading: isLoading,
        connected: isConnected,
        disabled: isDisabled,
        onTap: () => _handleTap(device, controller),
      ),
    );
  }

  Future<void> _handleTap(
    ObdDevice device,
    ObdScannerController controller,
  ) async {
    if (controller.connectingDeviceId != null) return;

    await controller.connect(device);
  }

  Widget _buildEmpty(WidgetRef ref) {
    return ObdEmptyState(
      onRetry: () async {
        await ref.read(obdScannerControllerProvider.notifier).scan();
      },
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(40),

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
      padding: const EdgeInsets.all(24),

      child: Center(child: Text(message)),
    );
  }
}

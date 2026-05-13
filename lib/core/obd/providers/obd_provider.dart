import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🔥 FIX: Update import paths sesuai struktur yang benar
import '../controllers/obd_live_data_controller.dart';
import '../controllers/obd_sender.dart';
import '../models/obd_capability.dart';
import '../models/obd_live_data.dart';
import '../services/obd_capability_service.dart';
import '../services/obd_command_service.dart';
import '../services/obd_discovery_service.dart';
import '../services/obd_parser_service.dart';
import '../services/obd_stream_service.dart';
import '../services/obd_telemetry_service.dart';
import '../services/obd_wifi_detector_service.dart';
import '../transport/base/obd_transport.dart';
import '../transport/bluetooth/obd_bluetooth_transport.dart';
import '../transport/wifi/obd_wifi_transport.dart';

// ============================
// TRANSPORT PROVIDERS
// ============================

final obdBluetoothTransportProvider = Provider<ObdBluetoothTransport>((ref) {
  final transport = ObdBluetoothTransport();
  ref.onDispose(() async {
    await transport.dispose();
  });
  return transport;
});

final obdWifiTransportProvider = Provider<ObdWifiTransport>((ref) {
  final transport = ObdWifiTransport();
  ref.onDispose(() async {
    await transport.dispose();
  });
  return transport;
});

// 🔥 FIX: Gunakan tipe konkret, bukan abstract (biar bisa di-cast)
final activeObdTransportProvider = StateProvider<ObdTransport?>((ref) => null);
// Atau untuk support kedua tipe:
// final activeObdTransportProvider = StateProvider<dynamic>((ref) => null);

// ============================
// 🔥 NEW: OBD SENDER PROVIDER
// ============================
// Provider ini menghubungkan transport dengan ObdSender typedef

final obdSenderProvider = Provider<ObdSender>((ref) {
  final transport = ref.watch(activeObdTransportProvider);

  if (transport == null) {
    throw StateError('No active transport. Please connect to a device first.');
  }

  // Return sendCommand function dari transport yang aktif
  return (String command) => transport.sendCommand(command);
});

// ============================
// SERVICE PROVIDERS
// ============================

final obdCommandProvider = Provider<ObdCommandService>((ref) {
  return ObdCommandService();
});

final obdParserProvider = Provider<ObdParserService>((ref) {
  return ObdParserService();
});

final obdDiscoveryProvider = Provider<ObdDiscoveryService>((ref) {
  return ObdDiscoveryService();
});

final obdWifiDetectorProvider = Provider<ObdWifiDetectorService>((ref) {
  return ObdWifiDetectorService();
});

// 🔥 FIX: Perbaiki dependensi ObdCapabilityProvider
final obdCapabilityProvider = FutureProvider.family<ObdCapability, ObdSender>((
  ref,
  send,
) async {
  final service = ObdCapabilityService();
  return service.detect(send: send);
});

// 🔥 FIX: Perbaiki dependensi ObdLiveDataControllerProvider
final obdLiveDataControllerProvider =
    StateNotifierProvider<ObdLiveDataController, AsyncValue<ObdLiveData>>((
      ref,
    ) {
      return ObdLiveDataController(
        streamService: ref.watch(obdStreamServiceProvider),
      );
    });

final obdTelemetryProvider = Provider<ObdTelemetryService>((ref) {
  return ObdTelemetryService();
});

final obdStreamServiceProvider = Provider<ObdStreamService>((ref) {
  final command = ref.read(obdCommandProvider);
  final parser = ref.read(obdParserProvider);
  final telemetry = ref.read(obdTelemetryProvider);

  final service = ObdStreamService(
    command: command,
    parser: parser,
    telemetry: telemetry,
  );

  ref.onDispose(() async {
    service.dispose();
  });

  return service;
});

// ============================
// 🔥 NEW: HELPER PROVIDER UNTUK CONNECTION STATE
// ============================

final obdConnectionStatusProvider = Provider<bool>((ref) {
  final transport = ref.watch(activeObdTransportProvider);
  return transport?.isConnected ?? false;
});

// ============================
// 🔥 NEW: PROVIDER UNTUK ACTIVE DEVICE NAME
// ============================

final obdActiveDeviceNameProvider = Provider<String?>((ref) {
  final transport = ref.watch(activeObdTransportProvider);
  return transport?.connectedDeviceName;
});

// ============================
// 🔥 NEW: COMBINED PROVIDER UNTUK UI STATE
// ============================

final obdUiStateProvider = Provider<ObdUiState>((ref) {
  final isConnected = ref.watch(obdConnectionStatusProvider);
  final deviceName = ref.watch(obdActiveDeviceNameProvider);
  final liveData = ref.watch(obdLiveDataControllerProvider);

  return ObdUiState(
    isConnected: isConnected,
    deviceName: deviceName,
    hasData: liveData.hasValue,
    latestData: liveData.valueOrNull,
  );
});

// ============================
// UI STATE MODEL
// ============================

class ObdUiState {
  final bool isConnected;
  final String? deviceName;
  final bool hasData;
  final ObdLiveData? latestData;

  const ObdUiState({
    required this.isConnected,
    this.deviceName,
    required this.hasData,
    this.latestData,
  });

  bool get isStreaming => isConnected && hasData;
}

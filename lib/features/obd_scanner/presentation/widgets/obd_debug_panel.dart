import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/obd/models/obd_live_data.dart';
import '../../../../core/obd/providers/obd_provider.dart';
import '../../../../core/obd/transport/base/obd_transport.dart';

class ObdDebugPanel extends ConsumerStatefulWidget {
  const ObdDebugPanel({super.key});

  @override
  ConsumerState<ObdDebugPanel> createState() => _ObdDebugPanelState();
}

class _ObdDebugPanelState extends ConsumerState<ObdDebugPanel> {
  final List<DebugLogEntry> _logs = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoggingEnabled = true;

  void addLog(String message, {DebugLogType type = DebugLogType.info}) {
    if (!_isLoggingEnabled) return;

    setState(() {
      _logs.insert(
        0,
        DebugLogEntry(message: message, type: type, timestamp: DateTime.now()),
      );

      // Keep only last 100 logs
      if (_logs.length > 100) {
        _logs.removeLast();
      }
    });

    // Auto scroll to top
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transport = ref.watch(activeObdTransportProvider);
    final isConnected = transport?.isConnected ?? false;
    final liveData = ref.watch(obdLiveDataControllerProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(isConnected, transport),

          // Live Data Preview
          _buildLiveDataPreview(liveData),

          // Log List
          Expanded(child: _buildLogList()),

          // Test Buttons
          _buildTestButtons(transport),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isConnected, ObdTransport? transport) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isConnected ? 'CONNECTED' : 'DISCONNECTED',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            transport?.connectedDeviceName ?? 'No device',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.white, size: 20),
            onPressed: clearLogs,
            tooltip: 'Clear logs',
          ),
          IconButton(
            icon: Icon(
              _isLoggingEnabled ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isLoggingEnabled = !_isLoggingEnabled;
              });
            },
            tooltip: _isLoggingEnabled ? 'Pause logging' : 'Resume logging',
          ),
        ],
      ),
    );
  }

  Widget _buildLiveDataPreview(AsyncValue<ObdLiveData> liveData) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade800,
      child: liveData.when(
        data: (data) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMiniCard(
                    'RPM',
                    data.rpm.toStringAsFixed(0),
                    Colors.orange,
                  ),
                  _buildMiniCard(
                    'Speed',
                    '${data.speed.toStringAsFixed(0)} km/h',
                    Colors.blue,
                  ),
                  _buildMiniCard(
                    'Coolant',
                    '${data.coolantTemp.toStringAsFixed(0)}°C',
                    Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMiniCard(
                    'Battery',
                    '${data.batteryVoltage.toStringAsFixed(1)}V',
                    Colors.green,
                  ),
                  _buildMiniCard(
                    'Load',
                    '${data.engineLoad.toStringAsFixed(0)}%',
                    Colors.purple,
                  ),
                  _buildMiniCard(
                    'MAF',
                    '${data.maf.toStringAsFixed(1)} g/s',
                    Colors.teal,
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Text('Error: $e', style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildMiniCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLogList() {
    if (_logs.isEmpty) {
      return const Center(
        child: Text(
          'No logs yet.\nTap "TEST RPM" to start debugging',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(8),
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final log = _logs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getLogColor(log.type),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  log.message,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getLogColor(DebugLogType type) {
    switch (type) {
      case DebugLogType.error:
        return Colors.red.withValues(alpha: 0.3);
      case DebugLogType.success:
        return Colors.green.withValues(alpha: 0.3);
      case DebugLogType.warning:
        return Colors.orange.withValues(alpha: 0.3);
      case DebugLogType.send:
        return Colors.blue.withValues(alpha: 0.3);
      case DebugLogType.receive:
        return Colors.purple.withValues(alpha: 0.3);
      default:
        return Colors.grey.withValues(alpha: 0.2);
    }
  }

  Widget _buildTestButtons(ObdTransport? transport) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildTestButton(
            label: 'TEST RPM',
            color: Colors.orange,
            onPressed: () => _testCommand(transport, '010C', 'RPM'),
          ),
          _buildTestButton(
            label: 'TEST SPEED',
            color: Colors.blue,
            onPressed: () => _testCommand(transport, '010D', 'SPEED'),
          ),
          _buildTestButton(
            label: 'TEST COOLANT',
            color: Colors.red,
            onPressed: () => _testCommand(transport, '0105', 'COOLANT'),
          ),
          _buildTestButton(
            label: 'TEST BATTERY',
            color: Colors.green,
            onPressed: () => _testCommand(transport, 'ATRV', 'BATTERY'),
          ),
          _buildTestButton(
            label: 'RAW ATZ',
            color: Colors.grey,
            onPressed: () => _testCommand(transport, 'ATZ', 'RESET'),
          ),
          _buildTestButton(
            label: 'RAW ATPP',
            color: Colors.purple,
            onPressed: () => _testCommand(transport, 'ATPP', 'PROTOCOL'),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      child: Text(label),
    );
  }

  Future<void> _testCommand(
    ObdTransport? transport,
    String command,
    String label,
  ) async {
    if (transport == null) {
      addLog(
        '❌ No active transport! Please connect first.',
        type: DebugLogType.error,
      );
      return;
    }

    addLog('📤 SENDING: $command ($label)', type: DebugLogType.send);

    try {
      final stopwatch = Stopwatch()..start();
      final response = await transport.sendCommand(command);
      stopwatch.stop();

      addLog('📥 RESPONSE: "$response"', type: DebugLogType.receive);
      addLog(
        '⏱️ Time: ${stopwatch.elapsedMilliseconds}ms',
        type: DebugLogType.info,
      );

      // Parse response based on command
      _parseAndLogResponse(command, response);

      addLog('✅ SUCCESS', type: DebugLogType.success);
    } catch (e) {
      addLog('❌ ERROR: $e', type: DebugLogType.error);
    }
  }

  void _parseAndLogResponse(String command, String response) {
    final upperResponse = response.toUpperCase();

    if (command == '010C') {
      // Parse RPM
      final pattern = RegExp(r'41\s*0C\s*([0-9A-F]{2})\s*([0-9A-F]{2})');
      final match = pattern.firstMatch(upperResponse);
      if (match != null) {
        final a = int.parse(match.group(1)!, radix: 16);
        final b = int.parse(match.group(2)!, radix: 16);
        final rpm = ((a * 256) + b) / 4;
        addLog(
          '📊 PARSED RPM: ${rpm.toStringAsFixed(1)}',
          type: DebugLogType.success,
        );
      } else {
        addLog(
          '⚠️ Could not parse RPM from response',
          type: DebugLogType.warning,
        );
        addLog(
          '   Expected pattern: "41 0C XX YY"',
          type: DebugLogType.warning,
        );
      }
    }

    if (command == '010D') {
      // Parse Speed
      final pattern = RegExp(r'41\s*0D\s*([0-9A-F]{2})');
      final match = pattern.firstMatch(upperResponse);
      if (match != null) {
        final speed = int.parse(match.group(1)!, radix: 16);
        addLog('📊 PARSED SPEED: $speed km/h', type: DebugLogType.success);
      }
    }

    if (command == '0105') {
      // Parse Coolant
      final pattern = RegExp(r'41\s*05\s*([0-9A-F]{2})');
      final match = pattern.firstMatch(upperResponse);
      if (match != null) {
        final coolant = int.parse(match.group(1)!, radix: 16) - 40;
        addLog('📊 PARSED COOLANT: $coolant °C', type: DebugLogType.success);
      }
    }

    if (command == 'ATRV') {
      // Parse Battery voltage (ELM327 internal)
      final pattern = RegExp(r'(\d+\.?\d*)V?');
      final match = pattern.firstMatch(upperResponse);
      if (match != null) {
        addLog(
          '📊 PARSED BATTERY: ${match.group(1)} V',
          type: DebugLogType.success,
        );
      }
    }
  }
}

class DebugLogEntry {
  final String message;
  final DebugLogType type;
  final DateTime timestamp;

  DebugLogEntry({
    required this.message,
    required this.type,
    required this.timestamp,
  });
}

enum DebugLogType { info, error, success, warning, send, receive }

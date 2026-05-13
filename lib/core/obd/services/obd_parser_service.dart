import '../helpers/obd_hex_helper.dart';

import '../helpers/obd_response_cleaner.dart';

class ObdParserService {
  List<String> _extractBytes(String raw) {
    final cleaned = ObdResponseCleaner.clean(raw);

    // 🔥 FIX: Support lowercase hex dengan mengubah regex
    return RegExp(
      r'\b[0-9A-Fa-f]{2}\b', // ← Tambahkan a-f untuk lowercase
    ).allMatches(cleaned).map((e) => e.group(0)!.toUpperCase()).toList();
  }

  bool _matchPid(List<String> bytes, int index, String pid) {
    // 🔥 FIX: Boundary check sebelum akses
    if (index + 1 >= bytes.length) return false;
    return bytes[index] == '41' && bytes[index + 1] == pid;
  }

  double _parse(
    String raw,
    String pid,
    double Function(List<String> bytes, int index) builder,
  ) {
    try {
      final bytes = _extractBytes(raw);

      // 🔥 FIX: Loop sampai length - 3 karena builder akses i+2 dan i+3
      for (int i = 0; i < bytes.length - 3; i++) {
        if (_matchPid(bytes, i, pid)) {
          // 🔥 FIX: Validasi tambahan untuk memastikan cukup bytes
          if (i + 3 >= bytes.length) {
            return -1;
          }
          return builder(bytes, i);
        }
      }
      return -1;
    } catch (_) {
      return -1;
    }
  }

  double rpm(String raw) {
    return _parse(raw, '0C', (b, i) {
      final a = ObdHexHelper.hex(b[i + 2]);
      final c = ObdHexHelper.hex(b[i + 3]);
      return ((a * 256) + c) / 4;
    });
  }

  double speed(String raw) {
    return _parse(raw, '0D', (b, i) {
      return ObdHexHelper.hex(b[i + 2]).toDouble();
    });
  }

  double coolant(String raw) {
    return _parse(raw, '05', (b, i) {
      return (ObdHexHelper.hex(b[i + 2]) - 40).toDouble();
    });
  }

  double engineLoad(String raw) {
    return _parse(raw, '04', (b, i) {
      return (ObdHexHelper.hex(b[i + 2]) * 100) / 255;
    });
  }

  double fuel(String raw) {
    return _parse(raw, '2F', (b, i) {
      return (ObdHexHelper.hex(b[i + 2]) * 100) / 255;
    });
  }

  double parseVoltage(String raw) {
    try {
      final upper = raw.toUpperCase();

      /// DIRECT VOLTAGE
      final voltageMatch = RegExp(r'(\d+\.\d+)V').firstMatch(upper);
      if (voltageMatch != null) {
        return double.parse(voltageMatch.group(1)!);
      }

      /// PID 42
      final bytes = _extractBytes(raw);

      // 🔥 FIX: Loop sampai length - 3
      for (int i = 0; i < bytes.length - 3; i++) {
        if (_matchPid(bytes, i, '42')) {
          final a = ObdHexHelper.hex(bytes[i + 2]);
          final b = ObdHexHelper.hex(bytes[i + 3]);
          return ((a * 256) + b) / 1000;
        }
      }
      return -1;
    } catch (_) {
      return -1;
    }
  }

  double parseMaf(String raw) {
    try {
      final bytes = _extractBytes(raw);

      // 🔥 FIX: Loop sampai length - 3
      for (int i = 0; i < bytes.length - 3; i++) {
        if (_matchPid(bytes, i, '10')) {
          final a = ObdHexHelper.hex(bytes[i + 2]);
          final b = ObdHexHelper.hex(bytes[i + 3]);
          final maf = ((a * 256) + b) / 100;
          if (maf < 0 || maf > 655) {
            return -1;
          }
          return maf;
        }
      }
      return -1;
    } catch (_) {
      return -1;
    }
  }

  bool isNoData(String raw) {
    return raw.toUpperCase().contains('NO DATA');
  }
}

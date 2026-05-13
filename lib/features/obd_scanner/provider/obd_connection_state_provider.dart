import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/obd_connection_state.dart';

final obdConnectionStateProvider = StateProvider<ObdConnectionState>((ref) {
  return ObdConnectionState.disconnected;
});

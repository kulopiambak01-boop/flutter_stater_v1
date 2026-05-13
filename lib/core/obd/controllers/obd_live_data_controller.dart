import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/obd_live_data.dart';
import '../services/obd_stream_service.dart';
import 'obd_sender.dart';

class ObdLiveDataController extends StateNotifier<AsyncValue<ObdLiveData>> {
  final ObdStreamService _streamService;

  StreamSubscription<ObdLiveData>? _subscription;

  bool _running = false;

  ObdLiveDataController({required ObdStreamService streamService})
    : _streamService = streamService,
      super(AsyncData(ObdLiveData.empty()));

  Future<void> start({required ObdSender send}) async {
    if (_running) return;

    _running = true;

    try {
      _streamService.start(send: send);

      await _subscription?.cancel();

      _subscription = _streamService.stream.listen(_onData, onError: _onError);
    } catch (e, st) {
      _running = false;

      state = AsyncError(e, st);
    }
  }

  void _onData(ObdLiveData data) {
    state = AsyncData(data);
  }

  void _onError(Object error, StackTrace stackTrace) {
    state = AsyncError(error, stackTrace);
  }

  Future<void> stop() async {
    if (!_running) return;

    _running = false;

    _streamService.stop();

    await _subscription?.cancel();

    _subscription = null;
  }

  bool get isRunning => _running;

  @override
  void dispose() {
    stop();

    super.dispose();
  }
}

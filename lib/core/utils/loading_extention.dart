import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/dialogs/global_loading_provider.dart';

extension LoadingExtension on Ref {
  void showLoading() {
    read(globalLoadingProvider.notifier).state = true;
  }

  void hideLoading() {
    read(globalLoadingProvider.notifier).state = false;
  }
}

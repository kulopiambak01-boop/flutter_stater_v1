import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/env.dart';
import 'core/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  EnvConfig.env = Env.dev;
  await ThemeService.init();

  runApp(const ProviderScope(child: MyApp()));
}

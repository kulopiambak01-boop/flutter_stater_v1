import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_provider.dart';

import '../data/datasource/auth_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';

import '../domain/entities/user.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecase/login_usecase.dart';

import '../presentation/controller/auth_controller.dart';

final authRemoteProvider = Provider(
  (ref) => AuthRemoteDataSource(ref.read(apiClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.read(authRemoteProvider)),
);

final loginUseCaseProvider = Provider(
  (ref) => LoginUseCase(ref.read(authRepositoryProvider)),
);

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<User?>>(
      (ref) => AuthController(ref),
    );

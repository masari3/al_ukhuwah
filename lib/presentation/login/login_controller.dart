//import 'package:flutter/material.dart';
import 'package:al_ukhuwah/di/providers.dart';
import 'package:al_ukhuwah/models/service_injection.dart';
import 'package:al_ukhuwah/models/user/login.dart';
import 'package:al_ukhuwah/res/strings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() async {}

  Future<Login?> login({
    required String phoneNumber,
    required String password,
    String? token,
  }) async {
    state = const AsyncLoading();
    final loginResult = await AsyncValue.guard(
      () => ref.watch(userServiceProvider).login(phoneNumber, password),
    );
    state = loginResult;
    final login = loginResult.valueOrNull?.firstOrNull;
    saveSession(login);
    return login;
  }

  Future<void> saveSession(
    Login? login,
  ) async {
    final pref = ref.read(sharedPreferencesHelperProvider);
    await pref.setObject(AppConstant.keyLoginSession, login);
    try {
      final token = await AsyncValue.guard(
        () => ref.read(firebaseMessagingProvider).getToken(),
      );
      await pref.setString(AppConstant.keyDeviceToken, token.valueOrNull ?? '');
    } catch (e) {}
  }
}

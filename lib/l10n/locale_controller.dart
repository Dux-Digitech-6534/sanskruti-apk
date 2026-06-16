import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.');
});

final localeControllerProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale> {
  static const _languageCodeKey = 'app_language_code';

  SharedPreferences get _preferences => ref.read(sharedPreferencesProvider);

  @override
  Locale build() {
    final code = _preferences.getString(_languageCodeKey) ?? 'en';
    return Locale(code == 'hi' ? 'hi' : 'en');
  }

  Future<void> setLocale(Locale locale) async {
    final code = locale.languageCode == 'hi' ? 'hi' : 'en';
    await _preferences.setString(_languageCodeKey, code);
    state = Locale(code);
  }
}

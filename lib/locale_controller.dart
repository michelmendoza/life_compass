import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// null = segue o idioma do sistema.
final ValueNotifier<Locale?> appLocale = ValueNotifier<Locale?>(null);

Future<void> loadSavedLocale(Box settingsBox) async {
  final code = settingsBox.get('locale') as String?;
  if (code != null) appLocale.value = Locale(code);
}

Future<void> setAppLocale(Box settingsBox, Locale? locale) async {
  appLocale.value = locale;
  if (locale == null) {
    await settingsBox.delete('locale');
  } else {
    await settingsBox.put('locale', locale.languageCode);
  }
}

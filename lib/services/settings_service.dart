import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

/// Хранит адрес бэкенда, который вводит пользователь (свой сервер с FastAPI).
class SettingsService {
  static const _key = 'backend_base_url';

  /// Адрес по умолчанию: сначала берётся значение, зашитое при сборке
  /// (--dart-define=BACKEND_URL=...), если его нет — localhost.
  static const defaultBaseUrl = AppConfig.backendUrl;

  Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? defaultBaseUrl;
  }

  Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    var clean = url.trim();
    if (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    await prefs.setString(_key, clean.isEmpty ? defaultBaseUrl : clean);
  }
}

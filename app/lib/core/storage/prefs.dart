import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static const _keyLanguage = 'vr_pref_language';
  static const _keyLastPortal = 'vr_pref_portal';
  static const _keyApiBaseUrl = 'vr_pref_api_base_url';

  static Future<String?> getApiBaseUrl() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_keyApiBaseUrl);
  }

  static Future<void> setApiBaseUrl(String url) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyApiBaseUrl, url);
  }

  static Future<String> getLanguage() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_keyLanguage) ?? 'en';
  }

  static Future<void> setLanguage(String lang) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyLanguage, lang);
  }

  static Future<String?> getLastPortal() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_keyLastPortal);
  }

  static Future<void> setLastPortal(String portal) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyLastPortal, portal);
  }
}

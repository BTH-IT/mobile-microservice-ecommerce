import 'package:shared_preferences/shared_preferences.dart';

class PreferenceStorage {
  static const _keyIsDarkMode = 'is_dark_mode';
  static const _keyUserEmail = 'remembered_user_email';
  static const _keySearchHistory = 'recent_search_history';

  final SharedPreferences _prefs;

  PreferenceStorage(this._prefs);

  static Future<PreferenceStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferenceStorage(prefs);
  }

  bool get isDarkMode => _prefs.getBool(_keyIsDarkMode) ?? false;

  Future<bool> setDarkMode(bool value) => _prefs.setBool(_keyIsDarkMode, value);

  String? get rememberedEmail => _prefs.getString(_keyUserEmail);

  Future<bool> setRememberedEmail(String email) => _prefs.setString(_keyUserEmail, email);

  Future<bool> clearRememberedEmail() => _prefs.remove(_keyUserEmail);

  List<String> get searchHistory => _prefs.getStringList(_keySearchHistory) ?? [];

  Future<bool> addSearchQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return false;
    final current = searchHistory.where((q) => q.toLowerCase() != trimmed.toLowerCase()).toList();
    current.insert(0, trimmed);
    if (current.length > 10) current.removeLast();
    return _prefs.setStringList(_keySearchHistory, current);
  }

  Future<bool> clearSearchHistory() => _prefs.remove(_keySearchHistory);
}

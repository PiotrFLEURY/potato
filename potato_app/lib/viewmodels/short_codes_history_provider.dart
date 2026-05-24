import 'package:potato/models/preferences/shared_preferences_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'short_codes_history_provider.g.dart';

@riverpod
class ShortCodeHistory extends _$ShortCodeHistory {
  @override
  Future<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(SharedPreferencesConstants.shortCodesHistory) ??
        [];
  }

  void cleanCodeFromHistory(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final history =
        prefs.getStringList(SharedPreferencesConstants.shortCodesHistory) ?? [];
    if (history.contains(code)) {
      history.remove(code);
      await prefs.setStringList(
        SharedPreferencesConstants.shortCodesHistory,
        history,
      );
    }
  }

  void historizeCode(String code) async {
    SharedPreferences.getInstance().then((prefs) {
      final history =
          prefs.getStringList(SharedPreferencesConstants.shortCodesHistory) ??
          [];
      if (code.isNotEmpty && !history.contains(code)) {
        history.insert(0, code);
        if (history.length > 10) {
          history.removeLast();
        }
        prefs.setStringList(
          SharedPreferencesConstants.shortCodesHistory,
          history,
        );
      }
    });
  }
}

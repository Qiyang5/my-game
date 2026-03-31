import 'package:shared_preferences/shared_preferences.dart';

class HighScoreStore {
  static const _key = 'best_score';

  Future<int> readBestScore() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_key) ?? 0;
  }

  Future<bool> writeIfHigher(int score) async {
    final preferences = await SharedPreferences.getInstance();
    final current = preferences.getInt(_key) ?? 0;
    if (score <= current) return false;
    return preferences.setInt(_key, score);
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';
import 'skins.dart';

/// Holds the look picked on this phone and persists it. Each member picks
/// their own; nothing about it is shared.
class ThemeController extends ChangeNotifier {
  static const _key = 'skin_id';

  SkinId _skin = SkinId.bina;

  SkinId get skin => _skin;
  AppColors get colors => kSkins[_skin]!;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_key);
    _skin = SkinId.values.firstWhere(
      (s) => s.name == id,
      orElse: () => SkinId.bina,
    );
    notifyListeners();
  }

  Future<void> select(SkinId skin) async {
    _skin = skin;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, skin.name);
  }
}

final ThemeController themeController = ThemeController();

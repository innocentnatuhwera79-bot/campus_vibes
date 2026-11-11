import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_helpers.dart';

class FavoritesStore {
  static const String _key = 'favorite_place_ids';

  static final ValueNotifier<Set<String>> favorites = ValueNotifier<Set<String>>({});

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    favorites.value = (prefs.getStringList(_key) ?? []).toSet();
  }

  static Future<void> toggle(String placeName) async {
    final id = placeIdFor(placeName);
    final updated = Set<String>.from(favorites.value);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    favorites.value = updated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, updated.toList());
  }
}
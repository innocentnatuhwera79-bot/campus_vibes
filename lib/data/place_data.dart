import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/place.dart';

List<Place>? _cachedPlaces;

Future<List<Place>> loadPlaces({bool forceReload = false}) async {
  if (_cachedPlaces != null && !forceReload) {
    return _cachedPlaces!;
  }
  final String jsonString = await rootBundle.loadString('lib/data/places.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  _cachedPlaces = jsonList.map((json) => Place.fromJson(json)).toList();
  return _cachedPlaces!;
}

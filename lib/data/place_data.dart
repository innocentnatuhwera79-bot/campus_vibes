import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/place.dart';

Future<List<Place>> loadPlaces() async {
  final String jsonString = await rootBundle.loadString('lib/data/places.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((json) => Place.fromJson(json)).toList();
}
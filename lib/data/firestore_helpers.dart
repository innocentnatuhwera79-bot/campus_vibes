String placeIdFor(String name) {
  return name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
}
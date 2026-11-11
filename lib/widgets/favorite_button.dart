import 'package:flutter/material.dart';
import '../data/favorites_store.dart';
import '../data/firestore_helpers.dart';

class FavoriteButton extends StatelessWidget {
  final String placeName;
  final Color? color;

  const FavoriteButton({super.key, required this.placeName, this.color});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: FavoritesStore.favorites,
      builder: (context, favorites, child) {
        final isFavorite = favorites.contains(placeIdFor(placeName));
        return IconButton(
          onPressed: () => FavoritesStore.toggle(placeName),
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.redAccent : color,
          ),
        );
      },
    );
  }
}